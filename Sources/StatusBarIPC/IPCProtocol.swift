import Foundation

/// Current IPC protocol version. Incremented when breaking changes are made.
public let ipcProtocolVersion: Int = 1

/// Default socket path for IPC communication.
/// Expand `~` at runtime via `FileManager.default.homeDirectoryForCurrentUser`.
public let ipcSocketName = "statusbar.sock"

/// Returns the full path to the IPC socket.
public func ipcSocketPath() -> String {
    FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/statusbar/\(ipcSocketName)").path
}

// MARK: - IPCRequest

/// Envelope sent from CLI to the app over the Unix socket.
public struct IPCRequest: Codable, Sendable, Equatable {
    public let version: Int
    public let requestID: String
    public let command: IPCCommand

    public init(version: Int = ipcProtocolVersion, requestID: String = UUID().uuidString, command: IPCCommand) {
        self.version = version
        self.requestID = requestID
        self.command = command
    }
}

// MARK: - IPCCommand

/// All supported IPC commands.
/// Not `@frozen` — new cases can be added in minor versions.
public enum IPCCommand: Codable, Sendable, Equatable {
    /// List all widgets with their layout and settings.
    case list
    /// Get details for a single widget.
    case getWidget(id: String)
    /// Set a single key on a widget's settings.
    case setWidget(id: String, key: String, value: ConfigValue)
    /// Set a global preference by dot-separated key path (e.g. "bar.height").
    case setGlobal(keyPath: String, value: ConfigValue)
    /// Reload configuration from disk.
    case reload
    /// Subscribe to events. The server keeps the connection open and pushes events as they fire.
    case subscribe(events: [String])
    /// Trigger a custom event, broadcasting to all matching subscribers.
    case trigger(event: String, env: [String: String])
    /// Create a new script widget at runtime.
    case addItem(id: String, position: WidgetPosition)
    /// Remove a script widget.
    case removeItem(id: String)
}

// MARK: - IPCResponse

/// Envelope sent from the app back to the CLI.
public struct IPCResponse: Codable, Sendable, Equatable {
    public let version: Int
    public let requestID: String
    public let result: IPCResult

    public init(version: Int = ipcProtocolVersion, requestID: String, result: IPCResult) {
        self.version = version
        self.requestID = requestID
        self.result = result
    }
}

// MARK: - IPCResult

/// Result payload — either success with data or a typed error.
public enum IPCResult: Codable, Sendable, Equatable {
    case success(IPCPayload)
    case failure(IPCError)
}

// MARK: - IPCPayload

/// Success payloads for each command type.
public enum IPCPayload: Codable, Sendable, Equatable {
    /// Response to `.list`.
    case widgetList([WidgetInfoDTO])
    /// Response to `.getWidget`.
    case widgetDetail(WidgetInfoDTO)
    /// Response to `.setWidget`, `.setGlobal`, `.reload`.
    case ok
    /// Event pushed to subscribe connections.
    case event(IPCEvent)
}

// MARK: - IPCError

/// Typed errors transmitted over the wire.
public enum IPCError: Codable, Sendable, Equatable, Error {
    case unknownCommand
    case widgetNotFound(id: String)
    case invalidKeyPath(String)
    case invalidValue(key: String, reason: String)
    case versionMismatch(serverVersion: Int, clientVersion: Int)
    case internalError(String)
    case itemAlreadyExists(id: String)
    case invalidProperty(String)
}

// MARK: - IPCEvent

/// An event pushed to subscribe connections.
public struct IPCEvent: Codable, Sendable, Equatable {
    public let event: String
    public let env: [String: String]
    public let timestamp: Date

    public init(event: String, env: [String: String] = [:], timestamp: Date = Date()) {
        self.event = event
        self.env = env
        self.timestamp = timestamp
    }
}
