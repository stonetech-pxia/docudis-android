import UIKit
import UniformTypeIdentifiers

/// "Share" → Docudis. Anonymizing needs the app (the NER model does not fit
/// in an extension's memory), so this only copies what was shared into the
/// App Group inbox and opens Docudis, which stages it on the home tab
/// (Runner/SharedInbox.swift reads the inbox).
///
/// Inbox layout: `Inbox/<uuid>/item.json` with either `{"text": …}` or
/// `{"file": "<name>"}`, the file next to it.
final class ShareViewController: UIViewController {
  static let appGroup = "group.com.stonetech.docudis"

  /// File types Docudis reads, as in TextExtractor.pickableExtensions.
  private static let fileTypes: [UTType] = [
    .pdf,
    UTType("org.openxmlformats.wordprocessingml.document")!,
    .image,
    .commaSeparatedText,
    UTType("net.daringfireball.markdown") ?? .plainText,
    .plainText,
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task { await handOver() }
  }

  private func handOver() async {
    let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
      .flatMap { $0.attachments ?? [] }
    var saved = false
    for provider in providers {
      do {
        if try await save(provider) {
          saved = true
          break
        }
      } catch {
        NSLog("Docudis share: \(error)")
      }
    }
    if saved, let url = URL(string: "docudis://shared") {
      await openApp(url)
    }
    extensionContext?.completeRequest(returningItems: nil)
  }

  /// Copies [provider]'s content into a new inbox entry. False when it is
  /// nothing Docudis reads.
  private func save(_ provider: NSItemProvider) async throws -> Bool {
    // Text typed or selected in another app arrives as a string, a text
    // file from Files as a file.
    if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
       !provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier),
       provider.suggestedName == nil,
       let text = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) as? String,
       !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      let entry = try newEntry()
      try write(["text": text], to: entry)
      return true
    }
    guard let type = Self.fileTypes.first(where: {
      provider.hasItemConformingToTypeIdentifier($0.identifier)
    }) else { return false }
    let entry = try newEntry()
    let name: String = try await withCheckedThrowingContinuation { done in
      // The URL is only valid inside this callback: copy it right away.
      _ = provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, error in
        guard let url else {
          done.resume(throwing: error ?? CocoaError(.fileReadUnknown))
          return
        }
        do {
          let name = Self.fileName(url: url, suggested: provider.suggestedName, type: type)
          try FileManager.default.copyItem(at: url, to: entry.appendingPathComponent(name))
          done.resume(returning: name)
        } catch {
          done.resume(throwing: error)
        }
      }
    }
    try write(["file": name], to: entry)
    return true
  }

  /// The sender's name when it has one, with the file's extension.
  private static func fileName(url: URL, suggested: String?, type: UTType) -> String {
    let ext = url.pathExtension.isEmpty
      ? (type.preferredFilenameExtension ?? "") : url.pathExtension
    var base = suggested ?? url.deletingPathExtension().lastPathComponent
    if !ext.isEmpty, base.lowercased().hasSuffix(".\(ext.lowercased())") {
      base = String(base.dropLast(ext.count + 1))
    }
    base = base.replacingOccurrences(of: "/", with: "_")
    if base.isEmpty { base = "shared" }
    return ext.isEmpty ? base : "\(base).\(ext)"
  }

  private func newEntry() throws -> URL {
    guard let group = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: Self.appGroup)
    else { throw CocoaError(.fileNoSuchFile) }
    var inbox = group.appendingPathComponent("Inbox", isDirectory: true)
    let entry = inbox.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: entry, withIntermediateDirectories: true)
    // What was shared waits here until the app opens it; keep it out of backups.
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? inbox.setResourceValues(values)
    return entry
  }

  /// item.json last: its presence marks the entry as complete.
  private func write(_ item: [String: String], to entry: URL) throws {
    let data = try JSONSerialization.data(withJSONObject: item)
    try data.write(to: entry.appendingPathComponent("item.json"), options: .atomic)
  }

  /// Share extensions have no API to open their app; the application object
  /// is reachable up the responder chain and still opens URLs.
  @MainActor
  private func openApp(_ url: URL) async {
    var responder: UIResponder? = self
    while let current = responder {
      if let application = current as? UIApplication {
        await application.open(url)
        return
      }
      responder = current.next
    }
  }
}
