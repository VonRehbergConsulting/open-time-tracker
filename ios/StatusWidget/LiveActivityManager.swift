import UIKit
import Flutter
import ActivityKit

@available(iOS 17.1, *)
class LiveActivityManager {
    var activity: Activity<StatusWidgetAttributes>?
    
    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLiveActivity":
            if let info = call.arguments as? [String: Any] {
                let startTimestamp = info["startTimestamp"] as? Double ?? 0
                let title = info["title"] as? String ?? ""
                startLiveActivity(startTimestamp: startTimestamp, title: title)
            }
        case "updateLiveActivity":
            if let info = call.arguments as? [String: Any] {
                let startTimestamp = info["startTimestamp"] as? Double ?? 0
                updateLiveActivity(startTimestamp: startTimestamp)
            }
        case "stopLiveActivity":
            stopLiveActivity()
        default:
            result(FlutterMethodNotImplemented)
        }
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
