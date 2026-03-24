import Foundation

// MARK: - WidgetConfigProvider

/// Protocol for widget settings that can be persisted to the YAML config file.
/// Each widget's Settings class conforms to this and registers with `WidgetConfigRegistry`.
@MainActor
public protocol WidgetConfigProvider: AnyObject {
    /// The widget ID used as the key in the YAML `widgetSettings` section.
    var configID: String { get }
    /// Export current settings as a flat dictionary.
    func exportConfig() -> [String: ConfigValue]
    /// Apply settings from a dictionary (hot-reload or initial load).
    func applyConfig(_ values: [String: ConfigValue])
}

// MARK: - WidgetConfigRegistry

/// Central registry for widget config providers. Lives in StatusBarKit so both
/// built-in widgets and plugins can register without importing the app target.
@MainActor
public final class WidgetConfigRegistry {
    public static let shared = WidgetConfigRegistry()

    /// Raw config data loaded from YAML, keyed by widget ID.
    private var loadedConfig: [String: [String: ConfigValue]] = [:]

    /// Registered providers for live widgets.
    private var providers: [String: WidgetConfigProvider] = [:]

    /// Callback invoked when a widget setting changes. Set by ConfigLoader.
    public var onSettingsChanged: (@MainActor () -> Void)?

    private init() {}

    /// Store loaded YAML widget settings. Called by ConfigLoader during bootstrap.
    public func setLoadedConfig(_ config: [String: [String: ConfigValue]]) {
        loadedConfig = config
    }

    /// Get config values for a widget. Called by Settings singletons in `init()`.
    public func values(for widgetID: String) -> [String: ConfigValue]? {
        loadedConfig[widgetID]
    }

    /// Register a settings provider. Called by each Settings singleton in `init()`.
    public func register(_ provider: WidgetConfigProvider) {
        providers[provider.configID] = provider
    }

    /// Apply loaded config to all registered providers (hot-reload).
    public func applyToAll() {
        for (id, provider) in providers {
            if let values = loadedConfig[id] {
                provider.applyConfig(values)
            }
        }
    }

    /// Export current settings from all registered providers.
    public func exportAll() -> [String: [String: ConfigValue]] {
        var result = loadedConfig
        for (id, provider) in providers {
            result[id] = provider.exportConfig()
        }
        return result
    }

    /// Notify that a widget setting changed (triggers YAML write-back).
    public func notifySettingsChanged() {
        onSettingsChanged?()
    }

    /// Reset all state. Intended for testing only.
    @_spi(Testing)
    public func reset() {
        loadedConfig = [:]
        providers = [:]
        onSettingsChanged = nil
    }
}
