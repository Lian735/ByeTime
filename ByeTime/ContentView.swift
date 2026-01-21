//
//  ContentView.swift
//  ByeTime
//
//  Created by Lian on 21.01.26.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var timerManager: SleepTimerManager
    @State private var hours: Int = 0
    @State private var minutes: Int = 30

    var body: some View {
        VStack(spacing: 16) {
            header
            countdownCard
            durationControls
            presetButtons
            actionButtons
        }
        .padding(20)
        .frame(width: 280)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("ByeTime")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Mac goes to sleep after your timer ends")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var countdownCard: some View {
        VStack(spacing: 8) {
            Text(timerManager.isRunning ? "Remaining" : "Ready")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(timerManager.isRunning ? timerManager.remainingFormatted : formattedDuration)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
            if let endDate = timerManager.endDate {
                Text("Sleep at \(endDate.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.06))
        )
    }

    private var durationControls: some View {
        VStack(spacing: 12) {
            Stepper(value: $hours, in: 0...12) {
                Text("Hours: \(hours)")
            }
            Stepper(value: $minutes, in: 0...59, step: 5) {
                Text("Minutes: \(minutes)")
            }
        }
    }

    private var presetButtons: some View {
        HStack(spacing: 8) {
            presetButton(label: "15m", minutes: 15)
            presetButton(label: "30m", minutes: 30)
            presetButton(label: "60m", minutes: 60)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                timerManager.start(durationSeconds: totalSeconds)
            } label: {
                Text(timerManager.isRunning ? "Restart Timer" : "Start Timer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(totalSeconds == 0)

            Button {
                timerManager.stop()
            } label: {
                Text("Stop")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!timerManager.isRunning)

            Divider()

            Button("Quit ByeTime") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }

    private func presetButton(label: String, minutes: Int) -> some View {
        Button(label) {
            hours = minutes / 60
            self.minutes = minutes % 60
        }
        .buttonStyle(.bordered)
    }

    private var totalSeconds: Int {
        (hours * 3600) + (minutes * 60)
    }

    private var formattedDuration: String {
        let totalMinutes = totalSeconds / 60
        let displayHours = totalMinutes / 60
        let displayMinutes = totalMinutes % 60
        if displayHours > 0 {
            return String(format: "%02d:%02d", displayHours, displayMinutes)
        }
        return String(format: "%02d:%02d", displayMinutes, 0)
    }
}

#Preview {
    ContentView()
        .environmentObject(SleepTimerManager())
}
