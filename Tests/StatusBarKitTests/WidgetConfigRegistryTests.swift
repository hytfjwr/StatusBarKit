import Testing
@testable @_spi(Testing) import StatusBarKit

// MARK: - MockConfigProvider

@MainActor
private final class MockConfigProvider: WidgetConfigProvider {
    let configID: String
    private(set) var appliedConfig: [String: ConfigValue]?

    init(configID: String) {
        self.configID = configID
    }

    func exportConfig() -> [String: ConfigValue] {
        appliedConfig ?? [:]
    }

    func applyConfig(_ values: [String: ConfigValue]) {
        appliedConfig = values
    }
}

// MARK: - WidgetConfigRegistryTests

struct WidgetConfigRegistryTests {
    @MainActor
    private func resetRegistry() {
        WidgetConfigRegistry.shared.reset()
    }

    @Test
    @MainActor
    func `values(for:) returns loaded config for known widget ID`() {
        resetRegistry()
        let registry = WidgetConfigRegistry.shared
        let config: [String: [String: ConfigValue]] = [
            "cpu": ["refresh": .int(5), "showLabel": .bool(true)],
        ]
        registry.setLoadedConfig(config)

        let values = registry.values(for: "cpu")
        #expect(values == ["refresh": .int(5), "showLabel": .bool(true)])
    }

    @Test
    @MainActor
    func `values(for:) returns nil for unknown widget ID`() {
        resetRegistry()
        let registry = WidgetConfigRegistry.shared
        registry.setLoadedConfig(["cpu": ["refresh": .int(5)]])

        #expect(registry.values(for: "weather") == nil)
    }

    @Test
    @MainActor
    func `register tracks provider by configID`() {
        resetRegistry()
        let registry = WidgetConfigRegistry.shared
        let provider = MockConfigProvider(configID: "battery")
        registry.register(provider)

        // Verify by loading config and applying — if registered, applyToAll will reach it
        registry.setLoadedConfig(["battery": ["threshold": .int(20)]])
        registry.applyToAll()

        #expect(provider.appliedConfig == ["threshold": .int(20)])
    }

    @Test
    @MainActor
    func `applyToAll applies config only to providers with matching loaded config`() {
        resetRegistry()
        let registry = WidgetConfigRegistry.shared
        let cpuProvider = MockConfigProvider(configID: "cpu")
        let weatherProvider = MockConfigProvider(configID: "weather")
        registry.register(cpuProvider)
        registry.register(weatherProvider)

        // Only load config for cpu
        registry.setLoadedConfig(["cpu": ["interval": .double(2.0)]])
        registry.applyToAll()

        #expect(cpuProvider.appliedConfig == ["interval": .double(2.0)])
        #expect(weatherProvider.appliedConfig == nil)
    }

    @Test
    @MainActor
    func `applyToAll does nothing for providers without loaded config`() {
        resetRegistry()
        let registry = WidgetConfigRegistry.shared
        let provider = MockConfigProvider(configID: "memory")
        registry.register(provider)

        registry.setLoadedConfig([:])
        registry.applyToAll()

        #expect(provider.appliedConfig == nil)
    }

    @Test
    @MainActor
    func `exportAll merges loaded config and live provider exports`() {
        resetRegistry()
        let registry = WidgetConfigRegistry.shared

        // Loaded config has an entry that no provider is registered for
        registry.setLoadedConfig([
            "disk": ["path": .string("/")],
            "cpu": ["old": .bool(false)],
        ])

        // Register a provider for cpu that exports different values
        let cpuProvider = MockConfigProvider(configID: "cpu")
        cpuProvider.applyConfig(["interval": .int(3)])
        registry.register(cpuProvider)

        let exported = registry.exportAll()

        // disk: from loaded config (no provider override)
        #expect(exported["disk"] == ["path": .string("/")])
        // cpu: overridden by live provider export
        #expect(exported["cpu"] == ["interval": .int(3)])
    }

    @Test
    @MainActor
    func `notifySettingsChanged fires the onSettingsChanged callback`() {
        resetRegistry()
        let registry = WidgetConfigRegistry.shared
        var callCount = 0
        registry.onSettingsChanged = { callCount += 1 }

        registry.notifySettingsChanged()
        registry.notifySettingsChanged()

        #expect(callCount == 2)
    }
}
