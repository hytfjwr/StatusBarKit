import Foundation

// MARK: - ToastLevel

/// Severity level for toast notifications.
/// Not `@frozen` — new levels can be added in minor versions.
public enum ToastLevel: String, Codable, Sendable, CaseIterable {
    case info
    case success
    case warning
    case error
}

// MARK: - ToastRequest

/// Wire-safe description of a toast notification.
/// Used by IPC commands, plugins, and internal callers alike.
public struct ToastRequest: Codable, Sendable, Equatable {
    public var title: String
    public var message: String?
    /// SF Symbol name. `nil` uses the level's default icon.
    public var icon: String?
    public var level: ToastLevel
    /// Auto-dismiss delay in seconds. `0` means persistent (manual dismiss only).
    public var duration: TimeInterval
    /// Label for the action button. `nil` means no action button.
    public var actionLabel: String?
    /// Shell command to run when the action button is tapped.
    public var actionShellCommand: String?

    public init(
        title: String,
        message: String? = nil,
        icon: String? = nil,
        level: ToastLevel = .info,
        duration: TimeInterval = 5,
        actionLabel: String? = nil,
        actionShellCommand: String? = nil,
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.level = level
        self.duration = duration
        self.actionLabel = actionLabel
        self.actionShellCommand = actionShellCommand
    }
}
