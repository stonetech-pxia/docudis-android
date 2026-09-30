import Flutter
import UIKit
import UniformTypeIdentifiers

/// iOS's system paste button (UIPasteControl) as a Flutter platform view.
///
/// Reading the clipboard with Clipboard.getData makes iOS ask "Allow Paste?"
/// on every tap unless the user changed the app's setting. A paste through
/// UIPasteControl is user-initiated by construction, so there is no prompt.
/// The label ("Paste", localised by iOS) and font are the system's; only the
/// colours and corners can be set. The control greys itself out while the
/// clipboard holds no text.
///
/// The control is drawn by the system out of process and reports no size
/// (intrinsicContentSize and sizeThatFits are zero even on screen), so
/// Flutter sizes it.
///
/// Dart side: lib/anonymize/ui/native_paste_button.dart. Each view gets its
/// own channel, `<viewType>/<view id>`, on which native calls "paste" with
/// the text.
enum PasteControl {
  static let viewType = "com.stonetech.docudis/paste_control"

  static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(Factory(messenger: registrar.messenger()), withId: viewType)
  }

  private final class Factory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
      self.messenger = messenger
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
      let channel = FlutterMethodChannel(name: "\(viewType)/\(viewId)", binaryMessenger: messenger)
      return PlatformView(TargetView(frame: frame, args: args as? [String: Any] ?? [:], channel: channel))
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
      FlutterStandardMessageCodec.sharedInstance()
    }
  }

  private final class PlatformView: NSObject, FlutterPlatformView {
    private let target: TargetView

    init(_ target: TargetView) {
      self.target = target
    }

    func view() -> UIView { target }
  }

  /// Hosts the control and is its paste target: UIPasteControl hands the
  /// clipboard items to `paste(itemProviders:)` of the responder it targets.
  private final class TargetView: UIView {
    private let channel: FlutterMethodChannel
    private let control: UIPasteControl

    init(frame: CGRect, args: [String: Any], channel: FlutterMethodChannel) {
      self.channel = channel
      let config = UIPasteControl.Configuration()
      config.displayMode = .iconAndLabel
      config.baseForegroundColor = color(args["foreground"]) ?? .white
      config.baseBackgroundColor = color(args["background"]) ?? .systemBlue
      if let radius = args["cornerRadius"] as? Double {
        config.cornerStyle = .fixed
        config.cornerRadius = radius
      } else {
        config.cornerStyle = .capsule
      }
      control = UIPasteControl(configuration: config)
      super.init(frame: frame)
      backgroundColor = .clear
      pasteConfiguration = UIPasteConfiguration(acceptableTypeIdentifiers: [UTType.text.identifier])
      control.target = self
      control.translatesAutoresizingMaskIntoConstraints = false
      addSubview(control)
      NSLayoutConstraint.activate([
        control.leadingAnchor.constraint(equalTo: leadingAnchor),
        control.trailingAnchor.constraint(equalTo: trailingAnchor),
        control.topAnchor.constraint(equalTo: topAnchor),
        control.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    override func paste(itemProviders: [NSItemProvider]) {
      guard let provider = itemProviders.first(where: { $0.canLoadObject(ofClass: String.self) }) else { return }
      _ = provider.loadObject(ofClass: String.self) { [weak self] text, _ in
        guard let text else { return }
        DispatchQueue.main.async { self?.channel.invokeMethod("paste", arguments: text) }
      }
    }
  }
}

/// ARGB int from Dart's Color.toARGB32().
private func color(_ value: Any?) -> UIColor? {
  guard let argb = (value as? NSNumber)?.uint32Value else { return nil }
  return UIColor(
    red: CGFloat((argb >> 16) & 0xFF) / 255,
    green: CGFloat((argb >> 8) & 0xFF) / 255,
    blue: CGFloat(argb & 0xFF) / 255,
    alpha: CGFloat((argb >> 24) & 0xFF) / 255
  )
}
