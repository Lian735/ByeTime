//
//  SettingsView.swift
//  ByeTime
//
//  Created by Lian on 21.01.26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("presetOneMinutes") private var presetOneMinutes: Int = 15
    @AppStorage("presetTwoMinutes") private var presetTwoMinutes: Int = 30
    @AppStorage("presetThreeMinutes") private var presetThreeMinutes: Int = 60
    @AppStorage("showSleepTime") private var showSleepTime: Bool = true

    var body: some View {
        Form {
            Section("Presets") {
                presetStepper(title: "Preset 1", value: $presetOneMinutes)
                presetStepper(title: "Preset 2", value: $presetTwoMinutes)
                presetStepper(title: "Preset 3", value: $presetThreeMinutes)
            }

            Section("Display") {
                Toggle("Show sleep time hint", isOn: $showSleepTime)
            }
        }
        .formStyle(.grouped)
        .frame(width: 320)
        .padding()
    }

    private func presetStepper(title: String, value: Binding<Int>) -> some View {
        Stepper(value: value, in: 5...240, step: 5) {
            Text("\(title): \(value.wrappedValue) minutes")
        }
    }
}

#Preview {
    SettingsView()
}
