import Foundation
import StatusBarKit
import Testing

struct PluginEventTests {

    @Test
    func `PluginEvent round-trips through Codable`() throws {
        let event = PluginEvent(
            name: "com.example.myapp.deploy_finished",
            payload: .object(["repo": .string("main")]),
            sourcePlugin: "com.example.other"
        )
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(PluginEvent.self, from: data)
        #expect(decoded.name == event.name)
        #expect(decoded.payload == event.payload)
        #expect(decoded.sourcePlugin == event.sourcePlugin)
    }

    @Test
    func `PluginEvent with nil payload round-trips`() throws {
        let event = PluginEvent(name: "com.example.myapp.ping")
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(PluginEvent.self, from: data)
        #expect(decoded.name == "com.example.myapp.ping")
        #expect(decoded.payload == nil)
        #expect(decoded.sourcePlugin == nil)
    }
}
