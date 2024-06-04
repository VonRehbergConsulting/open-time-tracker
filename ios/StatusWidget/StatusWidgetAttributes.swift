//
//  StatusWidgetAttributes.swift
//  Runner
//
//  Created by Denis Shtangey on 21.05.24.
//
import ActivityKit
import Foundation

struct StatusWidgetAttributes: ActivityAttributes {
    public typealias StatusWidgetStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var startTimestamp: Double
    }
    var title: String
    var subtitle: String
    var tag: String
}

