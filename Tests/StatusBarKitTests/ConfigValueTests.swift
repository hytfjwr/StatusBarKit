import Foundation
import Testing
@testable import StatusBarKit

@Suite("ConfigValue")
struct ConfigValueTests {
    // MARK: - Convenience Accessors

    @Test("String value accessor")
    func stringAccessor() {
        let v = ConfigValue.string("hello")
        #expect(v.stringValue == "hello")
        #expect(v.boolValue == nil)
        #expect(v.intValue == nil)
        #expect(v.doubleValue == nil)
    }

    @Test("Bool value accessor")
    func boolAccessor() {
        let v = ConfigValue.bool(true)
        #expect(v.boolValue == true)
        #expect(v.stringValue == nil)
        #expect(v.intValue == nil)
    }

    @Test("Int value accessor")
    func intAccessor() {
        let v = ConfigValue.int(42)
        #expect(v.intValue == 42)
        #expect(v.stringValue == nil)
        #expect(v.boolValue == nil)
    }

    @Test("Double value accessor")
    func doubleAccessor() {
        let v = ConfigValue.double(3.14)
        #expect(v.doubleValue == 3.14)
        #expect(v.stringValue == nil)
    }

    @Test("Int coerces to Double")
    func intCoercesToDouble() {
        let v = ConfigValue.int(10)
        #expect(v.doubleValue == 10.0)
    }

    // MARK: - Codable Round-Trip

    @Test("Encodes and decodes string")
    func roundTripString() throws {
        let original = ConfigValue.string("test")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("Encodes and decodes bool")
    func roundTripBool() throws {
        let original = ConfigValue.bool(false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("Encodes and decodes int")
    func roundTripInt() throws {
        let original = ConfigValue.int(99)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("Encodes and decodes double")
    func roundTripDouble() throws {
        let original = ConfigValue.double(2.718)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Equatable

    @Test("Equal values match")
    func equalValues() {
        #expect(ConfigValue.string("a") == ConfigValue.string("a"))
        #expect(ConfigValue.bool(true) == ConfigValue.bool(true))
        #expect(ConfigValue.int(1) == ConfigValue.int(1))
        #expect(ConfigValue.double(1.0) == ConfigValue.double(1.0))
    }

    @Test("Different cases are not equal")
    func differentCases() {
        #expect(ConfigValue.string("1") != ConfigValue.int(1))
        #expect(ConfigValue.int(1) != ConfigValue.double(1.0))
    }

    // MARK: - Decode Priority

    @Test("Bool is decoded before Int (JSON true)")
    func boolDecodedBeforeInt() throws {
        let json = Data("true".utf8)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: json)
        #expect(decoded == .bool(true))
    }

    @Test("Int is decoded before Double (JSON integer)")
    func intDecodedBeforeDouble() throws {
        let json = Data("42".utf8)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: json)
        #expect(decoded == .int(42))
    }

    @Test("Fractional number is decoded as Double")
    func fractionalAsDouble() throws {
        let json = Data("3.14".utf8)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: json)
        #expect(decoded == .double(3.14))
    }
}
