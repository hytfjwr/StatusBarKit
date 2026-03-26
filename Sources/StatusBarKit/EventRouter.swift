import Foundation

/// Routes `PluginEvent`s to widgets based on their `subscribedEvents` declarations.
///
/// Each widget's event suffixes are combined with the plugin's manifest ID to form
/// fully-qualified event names. Trailing `*` wildcards are supported for prefix matching.
@MainActor
public final class EventRouter {

    private struct Subscription {
        let pluginID: String
        /// The prefix to match against (pattern with trailing `*` stripped for wildcards).
        let matchPrefix: String
        let isWildcard: Bool
        let widget: AnyStatusBarWidget
    }

    private var subscriptions: [Subscription] = []

    public init() {}

    /// Register all widgets from a plugin, building subscriptions from each widget's
    /// `subscribedEvents` combined with the plugin's manifest ID.
    ///
    /// - Parameters:
    ///   - widgets: The plugin's type-erased widgets.
    ///   - pluginID: The plugin's manifest ID (e.g. "com.example.myapp").
    public func registerWidgets(_ widgets: [AnyStatusBarWidget], pluginID: String) {
        unregisterPlugin(pluginID)
        for widget in widgets {
            guard !widget.subscribedEvents.isEmpty else {
                continue
            }
            for suffix in widget.subscribedEvents {
                let fullyQualified = "\(pluginID).\(suffix)"
                let isWildcard = fullyQualified.hasSuffix("*")
                let matchPrefix = isWildcard ? String(fullyQualified.dropLast()) : fullyQualified
                subscriptions.append(Subscription(
                    pluginID: pluginID,
                    matchPrefix: matchPrefix,
                    isWildcard: isWildcard,
                    widget: widget,
                ))
            }
        }
    }

    /// Remove all subscriptions for a given plugin.
    public func unregisterPlugin(_ pluginID: String) {
        subscriptions.removeAll { $0.pluginID == pluginID }
    }

    /// Route an event to all matching widgets.
    public func route(_ event: PluginEvent) {
        for subscription in subscriptions where matches(eventName: event.name, subscription: subscription) {
            subscription.widget.handleEvent(event)
        }
    }

    /// Returns the number of active subscriptions (useful for testing).
    public var subscriptionCount: Int {
        subscriptions.count
    }

    // MARK: - Private

    private func matches(eventName: String, subscription: Subscription) -> Bool {
        if subscription.isWildcard {
            return eventName.hasPrefix(subscription.matchPrefix)
        }
        return eventName == subscription.matchPrefix
    }
}
