import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Backup-exclusion channel: lets Dart mark the database directory with
    // NSURLIsExcludedFromBackupKey so the encrypted store is kept out of
    // iCloud / encrypted Finder backups. Advisory per Apple, hence best-effort.
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.linnet.app/backup",
        binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, reply in
        guard call.method == "excludeFromBackup",
          let args = call.arguments as? [String: Any],
          let path = args["path"] as? String
        else {
          reply(FlutterMethodNotImplemented)
          return
        }
        var url = URL(fileURLWithPath: path)
        do {
          var values = URLResourceValues()
          values.isExcludedFromBackup = true
          try url.setResourceValues(values)
          reply(nil)
        } catch {
          reply(
            FlutterError(
              code: "exclude_failed",
              message: error.localizedDescription,
              details: nil))
        }
      }
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
