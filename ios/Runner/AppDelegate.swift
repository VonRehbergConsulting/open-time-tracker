import UIKit
import Flutter
import ActivityKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var activity: Activity<StatusWidgetAttributes>?
    
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
          channel.setMethodCallHandler({ [weak self] (
            call: FlutterMethodCall,
            result: @escaping FlutterResult) -> Void in
              switch call.method {
              case "startLiveActivity":
                  if let info = call.arguments as? [String: Any] {
                      let startTimestamp = info["startTimestamp"] as? Double ?? 0
                      let title = info["title"] as? String ?? ""
                      self?.startLiveActivity(startTimestamp: startTimestamp, title: title)
                  }
              case "updateLiveActivity":
                  if let info = call.arguments as? [String: Any] {
                      let startTimestamp = info["startTimestamp"] as? Double ?? 0
                      self?.updateLiveActivity(startTimestamp: startTimestamp)
                  }
              case "stopLiveActivity":
                  self?.stopLiveActivity()
              default:
                  result(FlutterMethodNotImplemented)
              }
          })
      }
      
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func startLiveActivity(startTimestamp: Double, title: String) {
        let state = StatusWidgetAttributes.ContentState(startTimestamp: startTimestamp)
        let activityAttributes = StatusWidgetAttributes(title: title)
        
        do {
            activity = try Activity.request(attributes: activityAttributes, contentState: state)
            print("ASD Requested a Live Activity \(activity?.id ?? "N/A")).")
        } catch (let error) {
            print("ASD Error requesting Live Activity \(error.localizedDescription).")
        }
    }
    
    func updateLiveActivity(startTimestamp: Double) {
        let state = StatusWidgetAttributes.ContentState(startTimestamp: startTimestamp)
        Task {
            await activity?.update(using: state)
        }
    }
    
    func stopLiveActivity() {
        
        Task {
            await activity?.end(using: nil, dismissalPolicy: .immediate)
        }
    }
}
