//
//  SettingsView.swift
//  ByeTime
//
//  Created by Lian on 21.01.26.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @AppStorage("presetOneMinutes") private var presetOneMinutes: Int = 15
    @AppStorage("presetTwoMinutes") private var presetTwoMinutes: Int = 30
    @AppStorage("presetThreeMinutes") private var presetThreeMinutes: Int = 60
    @AppStorage("showSleepTime") private var showSleepTime: Bool = true
    @AppStorage(MenuBarAnimationStyle.storageKey) private var menuBarAnimationStyleRaw: String = MenuBarAnimationStyle.rotating.rawValue

    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)

                    DispatchQueue.main.async {
                        if let window = NSApp.windows.first(where: { $0.isVisible }) {
                            window.makeKeyAndOrderFront(nil)
                            window.orderFrontRegardless()
                        }
                    }
                }
                .onDisappear {
                    NSApp.setActivationPolicy(.accessory)
                }

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("ByeTime").font(.headline)
                    }

                    Spacer()
                }

                Divider()

                HStack(spacing: 8) {
                    Image(systemName: "gear.badge.checkmark")
                        .foregroundStyle(.green.opacity(0.85))
                    Text("Settings are saved automatically")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                )
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Presets").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                        
                        presetStepper(title: "Preset 1", value: $presetOneMinutes)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: presetOneMinutes)
                        presetStepper(title: "Preset 2", value: $presetTwoMinutes)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: presetTwoMinutes)
                        presetStepper(title: "Preset 3", value: $presetThreeMinutes)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: presetThreeMinutes)
                    }

                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Display").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Toggle("Show sleep time hint", isOn: $showSleepTime)
                                .toggleStyle(.checkbox)
                            Spacer()
                        }
                        Picker("Menu bar animation", selection: $menuBarAnimationStyleRaw) {
                            ForEach(MenuBarAnimationStyle.allCases) { style in
                                Text(style.title).tag(style.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .help("Choose how the menu bar icon animates while the timer runs.")
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                )

                HStack {
                    Link(destination: URL(string: "https://www.moysoft.com")!) {
                        Image("moysoftfull")
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(height: 25)
                    }
                    Spacer()
                }
            }
            .padding(16)
            .frame(width: 360)
        }
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
