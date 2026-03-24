import Foundation

/// Data Transfer Object for widget info sent over IPC.
/// Contains no AppKit/SwiftUI types — safe for CLI consumption.
public struct WidgetInfoDTO: Codable, Sendable, Equatable {
    public let id: String
    public let displayName: String
    public let position: WidgetPosition
    public let sortIndex: Int
    public let isVisible: Bool
    public let settings: [String: ConfigValue]

    public init(
        id: String,
        displayName: String,
        position: WidgetPosition,
        sortIndex: Int,
        isVisible: Bool,
        settings: [String: ConfigValue],
    ) {
        self.id = id
        self.displayName = displayName
        self.position = position
        self.sortIndex = sortIndex
        self.isVisible = isVisible
        self.settings = settings
    }
}
