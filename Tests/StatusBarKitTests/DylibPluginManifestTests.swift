import Foundation
import Testing
@testable import StatusBarKit

@Suite("DylibPluginManifest")
struct DylibPluginManifestTests {
    @Test("Codable round-trip with all fields")
    func fullRoundTrip() throws {
        let original = DylibPluginManifest(
            id: "com.example.test",
            name: "Test Plugin",
            version: "1.2.3",
            statusBarKitVersion: "1.0.0",
            swiftVersion: "6.2",
            entrySymbol: "createPlugin",
            description: "A test plugin",
            author: "Test Author",
            homepage: "https://example.com",
            sha256: "abc123"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DylibPluginManifest.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.version == original.version)
        #expect(decoded.statusBarKitVersion == original.statusBarKitVersion)
        #expect(decoded.swiftVersion == original.swiftVersion)
        #expect(decoded.entrySymbol == original.entrySymbol)
        #expect(decoded.description == original.description)
        #expect(decoded.author == original.author)
        #expect(decoded.homepage == original.homepage)
        #expect(decoded.sha256 == original.sha256)
    }

    @Test("Codable round-trip with optional fields nil")
    func minimalRoundTrip() throws {
        let original = DylibPluginManifest(
            id: "com.example.minimal",
            name: "Minimal",
            version: "0.1.0",
            statusBarKitVersion: "1.0.0",
            swiftVersion: "6.2"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DylibPluginManifest.self, from: data)
        #expect(decoded.id == "com.example.minimal")
        #expect(decoded.entrySymbol == "createStatusBarPlugin")
        #expect(decoded.description == nil)
        #expect(decoded.author == nil)
        #expect(decoded.homepage == nil)
        #expect(decoded.sha256 == nil)
    }

    @Test("Default entry symbol")
    func defaultEntrySymbol() {
        let manifest = DylibPluginManifest(
            id: "com.example.default",
            name: "Default",
            version: "1.0.0",
            statusBarKitVersion: "1.0.0",
            swiftVersion: "6.2"
        )
        #expect(manifest.entrySymbol == "createStatusBarPlugin")
    }
}
