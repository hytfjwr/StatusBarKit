@testable import StatusBarKit
import Testing

struct PluginManifestTests {
    @Test
    func `Default version is 1.0.0`() {
        let manifest = PluginManifest(id: "com.example.test", name: "Test")
        #expect(manifest.version == "1.0.0")
    }

    @Test
    func `Custom version`() {
        let manifest = PluginManifest(id: "com.example.test", name: "Test", version: "2.3.1")
        #expect(manifest.version == "2.3.1")
    }

    @Test
    func `Stores id and name`() {
        let manifest = PluginManifest(id: "com.example.weather", name: "Weather")
        #expect(manifest.id == "com.example.weather")
        #expect(manifest.name == "Weather")
    }
}
