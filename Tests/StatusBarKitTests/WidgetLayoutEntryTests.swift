import Foundation
import Testing
@testable import StatusBarKit

@Suite("WidgetLayoutEntry")
struct WidgetLayoutEntryTests {
    @Test("Default isVisible is true")
    func defaultVisibility() {
        let entry = WidgetLayoutEntry(id: "cpu", section: .left, sortIndex: 0)
        #expect(entry.isVisible == true)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let original = WidgetLayoutEntry(id: "weather", section: .center, sortIndex: 2, isVisible: false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WidgetLayoutEntry.self, from: data)
        #expect(decoded == original)
    }

    @Test("Equatable")
    func equatable() {
        let a = WidgetLayoutEntry(id: "a", section: .left, sortIndex: 0)
        let b = WidgetLayoutEntry(id: "a", section: .left, sortIndex: 0)
        let c = WidgetLayoutEntry(id: "a", section: .right, sortIndex: 0)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Identifiable uses id")
    func identifiable() {
        let entry = WidgetLayoutEntry(id: "docker", section: .right, sortIndex: 1)
        #expect(entry.id == "docker")
    }
}
