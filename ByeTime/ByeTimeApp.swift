//
//  ByeTimeApp.swift
//  ByeTime
//
//  Created by Lian on 21.01.26.
//

import SwiftUI

@main
struct ByeTimeApp: App {
    @StateObject private var timerManager = SleepTimerManager()

    var body: some Scene {
        MenuBarExtra("ByeTime", systemImage: timerManager.isRunning ? "moon.zzz.fill" : "moon.zzz") {
            ContentView()
                .environmentObject(timerManager)
        }
        .menuBarExtraStyle(.window)
    }
}
