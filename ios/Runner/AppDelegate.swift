import UIKit
import Flutter
import ActivityKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var _liveActivityManager: Any? = nil
    @available(iOS 17.1, *)
    private var liveActivityManager: LiveActivityManager {
        if (_liveActivityManager == nil) {
            _liveActivityManager = LiveActivityManager()
        }
        return _liveActivityManager as! LiveActivityManager
    }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
       
      if let controller = window?.rootViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(
            name: "vonrehberg.timetracker.live-activity",
            binaryMessenger: controller.binaryMessenger
          )
          if #available(iOS 17.1, *) {
              channel.setMethodCallHandler(liveActivityManager.handle)
          }
      }
      
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
