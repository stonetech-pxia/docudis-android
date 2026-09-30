import Flutter
import UIKit

/// Probes AI apps (ChatGPT, Claude, ...) through their URL schemes, which must
/// be listed under LSApplicationQueriesSchemes in Info.plist. iOS cannot hand
/// content to one specific app, so sending stays on the Dart side (share sheet).
enum AiApps {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "com.stonetech.docudis/ai_apps", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard let args = call.arguments as? [String: Any],
            let scheme = args["scheme"] as? String,
            let url = URL(string: "\(scheme)://") else {
        result(FlutterError(code: "bad_args", message: "scheme is required", details: nil))
        return
      }
      switch call.method {
      case "isInstalled":
        result(UIApplication.shared.canOpenURL(url))
      case "open":
        guard UIApplication.shared.canOpenURL(url) else { result(false); return }
        UIApplication.shared.open(url) { result($0) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
