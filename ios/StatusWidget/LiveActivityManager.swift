import UIKit
import ActivityKit

@available(iOS 17.1, *)
class LiveActivityManager {
    var activity: Activity<StatusWidgetAttributes>?
    
    func startLiveActivity(startTimestamp: Double, title: String, subtitle: String, tag: String) {
        // Stop any existing activity before starting a new one
        // to prevent multiple Live Activities running simultaneously
        if let existingActivity = activity {
            Task {
                await existingActivity.end(using: nil, dismissalPolicy: .immediate)
            }
        }
        
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
