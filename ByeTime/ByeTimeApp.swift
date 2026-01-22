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
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        _timerManager = StateObject(wrappedValue: SleepTimerManager())
        statusBarController = StatusBarController(timerManager: _timerManager.wrappedValue)
    }

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
