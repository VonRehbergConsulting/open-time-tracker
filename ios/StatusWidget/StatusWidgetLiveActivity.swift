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
    let primaryColor = Color(red: 0.149, green: 0.36, blue: 0.725)
        
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
                    Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer)
                        .multilineTextAlignment(.trailing).frame(width: 90)
                        .foregroundStyle(.white)
                        .bold()
                }
                .padding(.horizontal)
                .activityBackgroundTint(primaryColor)

            } dynamicIsland: { context in
                DynamicIsland {
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
                                Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 90)
                            }.padding(.horizontal)
                        }
                    }
                } compactLeading: {
                    Image(systemName: "timer").padding(.leading, 4).foregroundColor(.blue)
                } compactTrailing: {
                
                    Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer)
                        .monospacedDigit()
                        .frame(width: 70)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                      
                    
                } minimal: {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                        .padding(.all, 4)
                }
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
