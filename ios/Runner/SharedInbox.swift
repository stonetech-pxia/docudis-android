import Flutter
import UIKit

/// Hands what the Share Extension saved (ShareExtension/ShareViewController)
/// to Dart on `com.stonetech.docudis/shared_input`, as SharedInput.kt does on
/// Android: `consume` returns the latest item (`{path, name}` or `{text}`)
/// and clears the inbox; `available` tells Dart one is waiting whenever the
/// app comes to the front (the extension opens `docudis://shared`).
enum SharedInbox {
  static let appGroup = "group.com.stonetech.docudis"
  private static var channel: FlutterMethodChannel?

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.stonetech.docudis/shared_input", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "consume": result(consume())
      default: result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
    NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
    ) { _ in
      if !entries().isEmpty { channel.invokeMethod("available", arguments: nil) }
    }
  }

  private static var inbox: URL? {
    FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
      .appendingPathComponent("Inbox", isDirectory: true)
  }

  /// Complete entries, newest first.
  private static func entries() -> [URL] {
    guard let inbox,
      let dirs = try? FileManager.default.contentsOfDirectory(
        at: inbox, includingPropertiesForKeys: [.creationDateKey])
    else { return [] }
    func created(_ url: URL) -> Date {
      (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
    }
    return dirs
      .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("item.json").path) }
      .sorted { created($0) > created($1) }
  }

  /// The newest item, its file moved into the app's temporary directory;
  /// every entry is removed, as only the last share counts.
  private static func consume() -> [String: String]? {
    let all = entries()
    defer { all.forEach { try? FileManager.default.removeItem(at: $0) } }
    guard let entry = all.first,
      let data = try? Data(contentsOf: entry.appendingPathComponent("item.json")),
      let item = try? JSONSerialization.jsonObject(with: data) as? [String: String]
    else { return nil }
    if let text = item["text"] { return ["text": text] }
    guard let name = item["file"] else { return nil }
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("shared/\(entry.lastPathComponent)", isDirectory: true)
    let target = dir.appendingPathComponent(name)
    do {
      try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
      try FileManager.default.moveItem(at: entry.appendingPathComponent(name), to: target)
    } catch {
      NSLog("Docudis shared file could not be moved: \(error)")
      return nil
    }
    return ["path": target.path, "name": name]
  }
}
