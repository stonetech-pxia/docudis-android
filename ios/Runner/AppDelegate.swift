import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeAppSupportFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// The records (originals and restore keys), the two term lists and the
  /// copied models live in Application Support. As on Android
  /// (android/app/src/main/res/xml), they stay out of iCloud and computer
  /// backups; the flag on the folder covers what is created in it later.
  private func excludeAppSupportFromBackup() {
    let fileManager = FileManager.default
    guard var dir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    else { return }
    try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? dir.setResourceValues(values)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AiApps") {
      AiApps.register(with: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ModelAssets") {
      ModelAssets.register(with: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PasteControl") {
      PasteControl.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SharedInbox") {
      SharedInbox.register(with: registrar.messenger())
    }
  }
}
