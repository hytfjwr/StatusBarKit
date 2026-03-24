import Foundation

/// The section of the status bar where a widget appears.
@available(macOS 15, *)
@_originallyDefinedIn(module: "StatusBarKit", macOS 15)
@frozen
public enum WidgetPosition: String, Codable, CaseIterable, Sendable {
    case left
    case center
    case right
}
