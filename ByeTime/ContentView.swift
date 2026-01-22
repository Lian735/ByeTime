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
    @State private var targetTime: Date = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
    @AppStorage("presetOneMinutes") private var presetOneMinutes: Int = 15
    @AppStorage("presetTwoMinutes") private var presetTwoMinutes: Int = 30
    @AppStorage("presetThreeMinutes") private var presetThreeMinutes: Int = 60
    @AppStorage("showSleepTime") private var showSleepTime: Bool = true
    @AppStorage("timerMode") private var timerModeRaw: String = TimerMode.duration.rawValue

    var body: some View {
        VStack(spacing: 16) {
            header
            countdownCard
            modePicker
            if !timerManager.isRunning {
                if timerMode == .duration {
                    durationControls
                    presetButtons
                } else {
                    targetTimeControls
                }
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
        .onChange(of: timerModeRaw) { _, _ in
            ensureTargetTimeAtLeastNextMinute()
        }
        .onChange(of: targetTime) { _, _ in
            ensureTargetTimeAtLeastNextMinute()
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
            if showSleepTime, let endDate = timerManager.endDate {
                Text("Sleep at \(endDate.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }

    private var modePicker: some View {
        Picker("Timer mode", selection: $timerModeRaw) {
            ForEach(TimerMode.allCases) { mode in
                Text(mode.title).tag(mode.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .disabled(timerManager.isRunning)
    }

    private var durationControls: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
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
            Spacer()
        }
    }

    private var targetTimeControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target time")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            DatePicker("", selection: $targetTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var presetButtons: some View {
        HStack(spacing: 8) {
            presetButton(label: "\(presetOneMinutes)m", minutes: presetOneMinutes)
            presetButton(label: "\(presetTwoMinutes)m", minutes: presetTwoMinutes)
            presetButton(label: "\(presetThreeMinutes)m", minutes: presetThreeMinutes)
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
                        let duration = totalSeconds
                        timerManager.start(durationSeconds: duration)
                        startedTotalSeconds = duration
                    }
                }
            } label: {
                Text(timerManager.isRunning ? "Stop" : "Start Timer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!timerManager.isRunning && totalSeconds == 0)
            
            Divider()
            
            HStack {
                SettingsLink {
                    Label("Open Settings", systemImage: "gear")
                }
                .buttonStyle(.glassProminent)
                .tint(.gray.opacity(0.5))
                .keyboardShortcut("s")
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .buttonStyle(.glassProminent)
                .tint(.red.opacity(0.5))
            }
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
        switch timerMode {
        case .duration:
            return (hours * 3600) + (minutes * 60)
        case .targetTime:
            return targetTimeSeconds
        }
    }

    private var targetTimeSeconds: Int {
        let now = Date()
        let calendar = Calendar.current
        var target = targetTime
        if target <= now {
            target = calendar.date(byAdding: .day, value: 1, to: target) ?? target
        }
        let remaining = Int(ceil(target.timeIntervalSince(now)))
        return max(remaining, 60)
    }

    private var formattedDuration: String {
        let total = totalSeconds
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private var timerMode: TimerMode {
        get { TimerMode(rawValue: timerModeRaw) ?? .duration }
        set { timerModeRaw = newValue.rawValue }
    }

    private func ensureTargetTimeAtLeastNextMinute() {
        guard timerMode == .targetTime else { return }
        let minimumDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        if targetTime < minimumDate {
            targetTime = minimumDate
        }
    }
}

private enum TimerMode: String, CaseIterable, Identifiable {
    case duration
    case targetTime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .duration:
            return "Duration"
        case .targetTime:
            return "Target time"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SleepTimerManager())
}
