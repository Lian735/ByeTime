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
    @State private var startedTotalSeconds: Int? = nil

    var body: some View {
        VStack(spacing: 16) {
            header
            countdownCard
            if !timerManager.isRunning {
                durationControls
                presetButtons
            } else {
                progressBar
            }
            actionButtons
        }
        .frame(width: 280)
        .padding()
        .onChange(of: timerManager.isRunning) { oldValue, newValue in
            if newValue == false {
                withAnimation(.easeInOut) {
                    startedTotalSeconds = nil
                }
            }
        }
        .animation(.bouncy, value: timerManager.isRunning)
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("ByeTime")
                        .font(.headline)
                }

                Spacer()
            }
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
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: timerManager.remainingSeconds)
                .animation(.easeInOut(duration: 0.2), value: formattedDuration)
            if let endDate = timerManager.endDate {
                Text("Sleep at \(endDate.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }

    private var durationControls: some View {
        VStack(spacing: 12) {
            Stepper(value: $hours, in: 0...12) {
                Text("Hours: \(hours)")
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: hours)
            }
            Stepper {
                Text("Minutes: \(minutes)")
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: minutes)
            } onIncrement: {
                let next = minutes + 5
                if next >= 60 {
                    minutes = 0
                    if hours < 12 { hours += 1 }
                } else {
                    minutes = next
                }
            } onDecrement: {
                let prev = minutes - 5
                if prev < 0 {
                    if hours > 0 { hours -= 1 }
                    minutes = 55
                } else {
                    minutes = prev
                }
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

    private var progressBar: some View {
        let total = startedTotalSeconds ?? totalSeconds
        let remaining = timerManager.remainingSeconds
        let progress = total > 0 ? Double(remaining) / Double(total) : 0
        return ProgressView(value: progress)
            .progressViewStyle(.linear)
            .tint(.green)
            .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation(.easeInOut) {
                    if timerManager.isRunning {
                        timerManager.stop()
                        startedTotalSeconds = nil
                    } else {
                        timerManager.start(durationSeconds: totalSeconds)
                        startedTotalSeconds = totalSeconds
                    }
                }
            } label: {
                Text(timerManager.isRunning ? "Stop" : "Start Timer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!timerManager.isRunning && totalSeconds == 0)
            
            Divider()

            Button("Quit ByeTime") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            .buttonStyle(.glassProminent)
            .tint(.red.opacity(0.5))
        }
    }

    private func presetButton(label: String, minutes: Int) -> some View {
        Button(label) {
            hours = minutes / 60
            self.minutes = minutes % 60
        }
        .buttonStyle(.glass)
    }

    private var totalSeconds: Int {
        (hours * 3600) + (minutes * 60)
    }

    private var formattedDuration: String {
        let total = totalSeconds
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ContentView()
        .environmentObject(SleepTimerManager())
}
