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
    private let timerManager = SleepTimerManager()
    private var statusBarController: StatusBarController!
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        statusBarController = StatusBarController(timerManager: timerManager)
    }

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(timerManager)
        }
        .defaultSize(width: 520, height: 420)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
