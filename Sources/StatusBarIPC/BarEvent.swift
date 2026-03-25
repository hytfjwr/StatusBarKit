import Foundation

// MARK: - BarEventName

/// Canonical event names for the subscribe system.
/// New events require a minor version bump to StatusBarKit.
public enum BarEventName: String, Codable, Sendable, CaseIterable {
    case frontAppSwitched = "front_app_switched"
    case volumeChanged = "volume_changed"
    case configReloaded = "config_reloaded"
}

// MARK: - BarEventPayload

/// Per-event payload carried inside an `IPCEventEnvelope`.
public enum BarEventPayload: Codable, Sendable, Equatable {
    case frontAppSwitched(appName: String, bundleID: String?)
    case volumeChanged(volume: Int, muted: Bool)
    case configReloaded
}

// MARK: - IPCEventEnvelope

/// A single event pushed to subscribers as newline-delimited JSON (NDJSON).
/// Sent after the initial `subscribeAck` handshake, without length-prefix framing.
public struct IPCEventEnvelope: Codable, Sendable, Equatable {
    public let event: BarEventName
    public let timestamp: Double
    public let payload: BarEventPayload

    public init(event: BarEventName, timestamp: Double = Date().timeIntervalSince1970, payload: BarEventPayload) {
        self.event = event
        self.timestamp = timestamp
        self.payload = payload
    }
}
