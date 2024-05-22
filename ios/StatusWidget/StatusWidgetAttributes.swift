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
        var elapsedSeconds: Int
    }
    
    var title: String
}

