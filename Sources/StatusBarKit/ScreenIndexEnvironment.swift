import SwiftUI

// MARK: - ScreenIndexKey

private struct ScreenIndexKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

public extension EnvironmentValues {
    /// The index of the screen this widget is rendered on (0-based). Used for multi-display support.
    var screenIndex: Int {
        get { self[ScreenIndexKey.self] }
        set { self[ScreenIndexKey.self] = newValue }
    }
}
