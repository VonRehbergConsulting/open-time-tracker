//
//  StatusWidget.swift
//  StatusWidget
//
//  Created by Denis Shtangey on 21.05.24.
//


import SwiftUI

@main
struct PizzaDeliveryWidgets: WidgetBundle {
    var body: some Widget {
        PizzaDeliveryActivityWidget()
        // Not working, it will crash your app or LiveActivity won't work
//        widget()
    }
}
