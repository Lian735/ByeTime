import Foundation

enum MenuBarAnimationStyle: String, CaseIterable, Identifiable {
    case pulsating
    case rotating
    case off

    static let storageKey = "menuBarAnimationStyle"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pulsating:
            return "Pulsating"
        case .rotating:
            return "Rotating"
        case .off:
            return "Off"
        }
    }
}
