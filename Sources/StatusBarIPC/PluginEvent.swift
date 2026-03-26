import Foundation

/// An event delivered to plugin widgets via the trigger system.
public struct PluginEvent: Sendable, Codable, Equatable {
    /// Fully-qualified event name (e.g. "com.example.myapp.deploy_finished").
    public let name: String

    /// Optional payload data.
    public let payload: JSONValue?

    /// When the event was created.
    public let timestamp: Date

    /// The manifest ID of the plugin that issued this trigger, or `nil` if sent from the CLI.
    public let sourcePlugin: String?

    public init(name: String, payload: JSONValue? = nil, timestamp: Date = Date(), sourcePlugin: String? = nil) {
        self.name = name
        self.payload = payload
        self.timestamp = timestamp
        self.sourcePlugin = sourcePlugin
    }
}
