//
//  ByeTimeApp.swift
//  ByeTime
//
//  Created by Lian on 21.01.26.
//

import SwiftUI
import AppKit

@main
struct ByeTimeApp: App {
    @StateObject private var timerManager: SleepTimerManager
    private var statusBarController: StatusBarController!

    init() {
        _timerManager = StateObject(wrappedValue: SleepTimerManager())
        statusBarController = StatusBarController(timerManager: _timerManager.wrappedValue)
    }

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1, height: 1)
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
}
