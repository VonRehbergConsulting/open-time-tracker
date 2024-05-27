//
//  StatusWidgetLiveActivity.swift
//  StatusWidget
//
//  Created by Denis Shtangey on 21.05.24.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct PizzaDeliveryActivityWidget: Widget {
    func getTimeString(_ seconds: Int) -> String {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let seconds = (seconds % 3600) % 60
            
            return hours == 0 ?
                    String(format: "%02d:%02d", minutes, seconds)
                    : String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        var body: some WidgetConfiguration {
            ActivityConfiguration(for: StatusWidgetAttributes.self) { context in
                // Lock screen/banner UI goes here
                HStack {
                    Text(context.attributes.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer().frame(width: 10)
                    Image(systemName: "timer")
                        .foregroundColor(.white)
                    Spacer().frame(width: 10)
                    Spacer()
                    Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer).multilineTextAlignment(.trailing).frame(width: 90).foregroundStyle(.white)
                }
                .padding(.horizontal)
                .activityBackgroundTint(Color.black.opacity(0.5))

            } dynamicIsland: { context in
                DynamicIsland {
                    // Expanded UI goes here.  Compose the expanded UI through
                    // various regions, like leading/trailing/center/bottom
                    DynamicIslandExpandedRegion(.center) {
                        VStack(alignment: .center) {
                            Text("Time Tracker")
                            Spacer().frame(height: 24)
                            HStack {
                                Text(context.attributes.title)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer().frame(width: 10)
                                Image(systemName: "timer")
                                    .foregroundColor(.white)
                                Spacer().frame(width: 10)
                                Spacer()
                                Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer).multilineTextAlignment(.trailing).frame(width: 90)
                            }.padding(.horizontal)
                        }
                    }
                } compactLeading: {
                    Image(systemName: "timer").padding(.leading, 4)
                } compactTrailing: {
                
                    Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer).monospacedDigit()
                        .frame(width: 70)
                      
                    
                } minimal: {
                    Image(systemName: "timer")
                        .foregroundColor(.yellow)
                        .padding(.all, 4)
                }
                .widgetURL(URL(string: "http://www.apple.com"))
                .keylineTint(Color.red)
            }
        }
}

//struct LockScreenLiveActivityView: View {
//    let context: ActivityViewContext<PizzaDeliveryAttributes>
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            Text("\(context.state.driverName) is on their way with your 21!")
//            Spacer()
//            HStack {
//                Spacer()
//                Label {
//                    Text("\(context.attributes.totalAmount) Pizzas")
//                } icon: {
//                    Image(systemName: "bag")
//                        .foregroundColor(.indigo)
//                }
//                .font(.title2)
//                Spacer()
//                Label {
//                    Text(timerInterval: context.state.deliveryTimer, countsDown: true)
//                        .multilineTextAlignment(.center)
//                        .frame(width: 50)
//                        .monospacedDigit()
//                } icon: {
//                    Image(systemName: "timer")
//                        .foregroundColor(.indigo)
//                }
//                .font(.title2)
//                Spacer()
//            }
//            Spacer()
//        }
//        .activitySystemActionForegroundColor(.indigo)
//        .activityBackgroundTint(.cyan)
//    }
//}
