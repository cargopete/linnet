import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// A blur view placed over the UI whenever the app becomes inactive, so the
  /// app-switcher snapshot never reveals on-screen reproductive-health data.
  /// This is independent of the in-app biometric lock and always applies.
  private var privacyOverlay: UIView?

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

    // Obscure the app-switcher snapshot the instant the app goes inactive, and
    // clear it when it returns. UIApplication lifecycle notifications fire for
    // scene-based apps too, so this works without overriding the scene delegate.
    let center = NotificationCenter.default
    center.addObserver(
      self, selector: #selector(obscureForPrivacy),
      name: UIApplication.willResignActiveNotification, object: nil)
    center.addObserver(
      self, selector: #selector(revealAfterPrivacy),
      name: UIApplication.didBecomeActiveNotification, object: nil)

    return result
  }

  @objc private func obscureForPrivacy() {
    guard privacyOverlay == nil, let window = activeKeyWindow() else { return }
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
    blur.frame = window.bounds
    blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(blur)
    privacyOverlay = blur
  }

  @objc private func revealAfterPrivacy() {
    privacyOverlay?.removeFromSuperview()
    privacyOverlay = nil
  }

  private func activeKeyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
      ?? window
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
