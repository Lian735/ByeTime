import SwiftUI
import AppKit
import Combine

class StatusBarController {
    let statusItem: NSStatusItem
    let popover: NSPopover
    private var isRunningCancellable: AnyCancellable?
    private var resignObserver: Any?
    private var settingsObserver: Any?
    private var rotationTimer: Timer?
    private var isRunning: Bool = false

    init(timerManager: SleepTimerManager) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()

        if let button = statusItem.button {
            if let image = NSImage(named: "ByeTimeLogo") {
                image.isTemplate = true
                image.size = NSSize(width: 24, height: 24)
                button.image = image
            }
            button.target = self
            button.action = #selector(togglePopover(_:))
        }

        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentSize = NSSize(width: 300, height: 360)
        popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(timerManager))

        popover.behavior = .transient

        isRunningCancellable = timerManager.$isRunning.sink { [weak self] isRunning in
            DispatchQueue.main.async {
                self?.isRunning = isRunning
                if let button = self?.statusItem.button {
                    if let image = NSImage(named: "ByeTimeLogo") {
                        image.isTemplate = true
                        image.size = NSSize(width: 24, height: 24)
                        button.image = image
                    }

                    self?.applyAnimation(to: button, isRunning: isRunning)
                }
            }
        }

        settingsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, let button = self.statusItem.button else { return }
            self.applyAnimation(to: button, isRunning: self.isRunning)
        }
    }

    deinit {
        if let button = statusItem.button {
            stopRotation(on: button)
        }
        rotationTimer?.invalidate()
        rotationTimer = nil

        if let settingsObserver {
            NotificationCenter.default.removeObserver(settingsObserver)
            self.settingsObserver = nil
        }

        if let resignObserver {
            NotificationCenter.default.removeObserver(resignObserver)
            self.resignObserver = nil
        }
    }

    private func startRotation(on button: NSStatusBarButton) {
        stopRotation(on: button)
        stopPulsating(on: button)

        button.wantsLayer = true

        guard let layer = button.layer else { return }

        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(
            x: button.bounds.midX,
            y: button.bounds.midY
        )

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * Double.pi
        animation.duration = 8.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.isRemovedOnCompletion = false

        layer.add(animation, forKey: "rotation")
    }

    private func stopRotation(on button: NSStatusBarButton) {
        guard let layer = button.layer else { return }

        // Stop continuous rotation
        let currentRotation = (layer.presentation()?.value(forKeyPath: "transform.rotation.z") as? CGFloat) ?? 0
        layer.removeAnimation(forKey: "rotation")

        // Bouncy reset back to 0 rotation
        let spring = CASpringAnimation(keyPath: "transform.rotation.z")
        spring.fromValue = currentRotation
        spring.toValue = 0
        spring.damping = 10
        spring.stiffness = 120
        spring.mass = 1
        spring.initialVelocity = 0
        spring.duration = spring.settlingDuration
        spring.timingFunction = CAMediaTimingFunction(name: .easeOut)

        layer.add(spring, forKey: "rotationReset")

        // Ensure final state is clean
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.setValue(0, forKeyPath: "transform.rotation.z")
        CATransaction.commit()
    }

    private func startPulsating(on button: NSStatusBarButton) {
        stopPulsating(on: button)
        stopRotation(on: button)

        button.wantsLayer = true

        guard let layer = button.layer else { return }

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.35
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false

        layer.add(animation, forKey: "pulsating")
    }

    private func stopPulsating(on button: NSStatusBarButton) {
        guard let layer = button.layer else { return }

        layer.removeAnimation(forKey: "pulsating")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.opacity = 1.0
        CATransaction.commit()
    }

    private func applyAnimation(to button: NSStatusBarButton, isRunning: Bool) {
        if !isRunning {
            stopRotation(on: button)
            stopPulsating(on: button)
            return
        }

        let style = currentAnimationStyle()
        switch style {
        case .rotating:
            startRotation(on: button)
        case .pulsating:
            startPulsating(on: button)
        case .off:
            stopRotation(on: button)
            stopPulsating(on: button)
        }
    }

    private func currentAnimationStyle() -> MenuBarAnimationStyle {
        let storedValue = UserDefaults.standard.string(forKey: MenuBarAnimationStyle.storageKey)
        return MenuBarAnimationStyle(rawValue: storedValue ?? MenuBarAnimationStyle.rotating.rawValue) ?? .rotating
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    func showPopover() {
        if let button = statusItem.button, let buttonWindow = button.window {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            buttonWindow.makeKey()
            if let window = popover.contentViewController?.view.window {
                window.makeKeyAndOrderFront(nil)
                // Try to make the SwiftUI hosting view first responder for keyboard focus
                window.makeFirstResponder(window.firstResponder)

                resignObserver = NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: window, queue: .main) { [weak self] _ in
                    self?.closePopover()
                }
            }
        }
    }

    func closePopover() {
        if let resignObserver {
            NotificationCenter.default.removeObserver(resignObserver)
            self.resignObserver = nil
        }
        popover.performClose(nil)
    }
}
