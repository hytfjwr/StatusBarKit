import Foundation
@testable import StatusBarKit
import Testing

struct ConfigValueTests {

    // MARK: - Convenience Accessors

    @Test
    func `String value accessor`() {
        let v = ConfigValue.string("hello")
        #expect(v.stringValue == "hello")
        #expect(v.boolValue == nil)
        #expect(v.intValue == nil)
        #expect(v.doubleValue == nil)
    }

    @Test
    func `Bool value accessor`() {
        let v = ConfigValue.bool(true)
        #expect(v.boolValue == true)
        #expect(v.stringValue == nil)
        #expect(v.intValue == nil)
    }

    @Test
    func `Int value accessor`() {
        let v = ConfigValue.int(42)
        #expect(v.intValue == 42)
        #expect(v.stringValue == nil)
        #expect(v.boolValue == nil)
    }

    @Test
    func `Double value accessor`() {
        let v = ConfigValue.double(3.14)
        #expect(v.doubleValue == 3.14)
        #expect(v.stringValue == nil)
    }

    @Test
    func `Int coerces to Double`() {
        let v = ConfigValue.int(10)
        #expect(v.doubleValue == 10.0)
    }

    // MARK: - Codable Round-Trip

    @Test
    func `Encodes and decodes string`() throws {
        let original = ConfigValue.string("test")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `Encodes and decodes bool`() throws {
        let original = ConfigValue.bool(false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `Encodes and decodes int`() throws {
        let original = ConfigValue.int(99)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `Encodes and decodes double`() throws {
        let original = ConfigValue.double(2.718)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Equatable

    @Test
    func `Equal values match`() {
        #expect(ConfigValue.string("a") == ConfigValue.string("a"))
        #expect(ConfigValue.bool(true) == ConfigValue.bool(true))
        #expect(ConfigValue.int(1) == ConfigValue.int(1))
        #expect(ConfigValue.double(1.0) == ConfigValue.double(1.0))
    }

    @Test
    func `Different cases are not equal`() {
        #expect(ConfigValue.string("1") != ConfigValue.int(1))
        #expect(ConfigValue.int(1) != ConfigValue.double(1.0))
    }

    // MARK: - Decode Priority

    @Test
    func `Bool is decoded before Int (JSON true)`() throws {
        let json = Data("true".utf8)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: json)
        #expect(decoded == .bool(true))
    }

    @Test
    func `Int is decoded before Double (JSON integer)`() throws {
        let json = Data("42".utf8)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: json)
        #expect(decoded == .int(42))
    }

    @Test
    func `Fractional number is decoded as Double`() throws {
        let json = Data("3.14".utf8)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: json)
        #expect(decoded == .double(3.14))
    }
}
