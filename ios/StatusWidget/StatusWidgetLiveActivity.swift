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
                HStack {
                    VStack {
                        HStack {
                            Text(context.attributes.tag)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 4.0)
                                .padding(.horizontal, 8.0)
                                .background(primaryColor)
                                .cornerRadius(20)
                            Spacer().frame(width: 8.0)
                            Spacer()
                            Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.white)
                                .bold()
                        }
                        HStack {
                            Text(context.attributes.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        Spacer().frame(height: 2.0)
                        HStack {
                            Text(context.attributes.subtitle)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                       
                    }
                    
                }
                .padding(.all)
                .activityBackgroundTint(.black.opacity(0.5))

            } dynamicIsland: { context in
                DynamicIsland {
                    DynamicIslandExpandedRegion(.leading) {
                        Text(context.attributes.tag)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 4.0)
                            .padding(.horizontal, 8.0)
                            .background(primaryColor)
                            .cornerRadius(20)
                            .padding(.leading, 4.0)
                    }
                    DynamicIslandExpandedRegion(.trailing) {
                        Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.trailing, 4.0)
                    }
                    DynamicIslandExpandedRegion(.bottom) {
                        HStack {
                            VStack {
                                HStack {
                                    Text(context.attributes.title)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                Spacer().frame(height: 2.0)
                                HStack {
                                    Text(context.attributes.subtitle)
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                               
                            }
                            
                        }
                        .padding(.leading, 4.0)
                        .padding(.trailing, 4.0)
                    }
                } compactLeading: {
                    Image(systemName: "timer").padding(.leading, 4).foregroundColor(.white)
                } compactTrailing: {
                    Text(Date(timeIntervalSince1970: context.state.startTimestamp), style: .timer)
                        .monospacedDigit()
                        .frame(width: 70)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                } minimal: {
                    Image(systemName: "timer")
                        .foregroundColor(.white)
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
