import Foundation

/// The section of the status bar where a widget appears.
@frozen
public enum WidgetPosition: String, Codable, CaseIterable, Sendable {
    case left
    case center
    case right
}
