import Foundation

// MARK: - BarEvent

/// Well-known event names provided by StatusBarKit.
/// Host applications may define additional event names as plain strings.
public enum BarEvent {
    /// Emitted when configuration is reloaded from disk.
    public static let configReloaded = "config_reloaded"
}

// MARK: - IPCEventEnvelope

/// A single event pushed to subscribers as newline-delimited JSON (NDJSON).
/// Sent after the initial `subscribeAck` handshake, without length-prefix framing.
public struct IPCEventEnvelope: Codable, Sendable, Equatable {
    public let event: String
    public let timestamp: Double
    public let payload: JSONValue?

    public init(event: String, timestamp: Double = Date().timeIntervalSince1970, payload: JSONValue? = nil) {
        self.event = event
        self.timestamp = timestamp
        self.payload = payload
    }
}
