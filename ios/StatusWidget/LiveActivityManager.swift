import UIKit
import ActivityKit

@available(iOS 17.1, *)
class LiveActivityManager {
    var activity: Activity<StatusWidgetAttributes>?
    
    func startLiveActivity(startTimestamp: Double, title: String, subtitle: String, tag: String) {
        let state = StatusWidgetAttributes.ContentState(startTimestamp: startTimestamp)
        let activityAttributes = StatusWidgetAttributes(title: title, subtitle: subtitle, tag: tag)
        
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
