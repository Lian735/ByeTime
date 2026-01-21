//
//  SleepTimerManager.swift
//  ByeTime
//
//  Created by Lian on 21.01.26.
//

import Foundation
import os

final class SleepTimerManager: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var endDate: Date?
    @Published private(set) var remainingSeconds: Int = 0

    private var timer: Timer?
    private let logger = Logger(subsystem: "ByeTime", category: "SleepTimer")

    func start(durationSeconds: Int) {
        guard durationSeconds > 0 else { return }
        stop()
        let endDate = Date().addingTimeInterval(TimeInterval(durationSeconds))
        self.endDate = endDate
        remainingSeconds = durationSeconds
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        endDate = nil
        remainingSeconds = 0
    }

    var remainingFormatted: String {
        guard remainingSeconds > 0 else { return "00:00" }
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func tick() {
        guard let endDate else { return }
        let remaining = Int(endDate.timeIntervalSinceNow.rounded(.down))
        if remaining <= 0 {
            stop()
            triggerSleep()
        } else {
            remainingSeconds = remaining
        }
    }

    private func triggerSleep() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["sleepnow"]

        do {
            try process.run()
        } catch {
            logger.error("Failed to trigger sleep: \(error.localizedDescription)")
        }
    }
}
