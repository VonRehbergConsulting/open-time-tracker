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
              channel.setMethodCallHandler(handle)
          }
      }
      
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    @available(iOS 17.1, *)
    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLiveActivity":
            if let info = call.arguments as? [String: Any] {
                let startTimestamp = info["startTimestamp"] as? Double ?? 0
                let title = info["title"] as? String ?? ""
                let subtitle = info["subtitle"] as? String ?? ""
                let tag = info["tag"] as? String ?? ""
                liveActivityManager.startLiveActivity(startTimestamp: startTimestamp, title: title, subtitle: subtitle, tag: tag)
            }
        case "updateLiveActivity":
            if let info = call.arguments as? [String: Any] {
                let startTimestamp = info["startTimestamp"] as? Double ?? 0
                liveActivityManager.updateLiveActivity(startTimestamp: startTimestamp)
            }
        case "stopLiveActivity":
            liveActivityManager.stopLiveActivity()
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
