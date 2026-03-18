import Testing
@testable import StatusBarKit

@Suite("PluginManifest")
struct PluginManifestTests {
    @Test("Default version is 1.0.0")
    func defaultVersion() {
        let manifest = PluginManifest(id: "com.example.test", name: "Test")
        #expect(manifest.version == "1.0.0")
    }

    @Test("Custom version")
    func customVersion() {
        let manifest = PluginManifest(id: "com.example.test", name: "Test", version: "2.3.1")
        #expect(manifest.version == "2.3.1")
    }

    @Test("Stores id and name")
    func storesFields() {
        let manifest = PluginManifest(id: "com.example.weather", name: "Weather")
        #expect(manifest.id == "com.example.weather")
        #expect(manifest.name == "Weather")
    }
}
