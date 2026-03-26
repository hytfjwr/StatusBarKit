import Foundation
import StatusBarKit
import Testing

struct JSONValueTests {

    // MARK: - Codable round-trips

    @Test
    func `String round-trips through Codable`() throws {
        let value = JSONValue.string("hello")
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == value)
    }

    @Test
    func `Number round-trips through Codable`() throws {
        let value = JSONValue.number(42.5)
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == value)
    }

    @Test
    func `Bool round-trips through Codable`() throws {
        let value = JSONValue.bool(true)
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == value)
    }

    @Test
    func `Null round-trips through Codable`() throws {
        let value = JSONValue.null
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == value)
    }

    @Test
    func `Array round-trips through Codable`() throws {
        let value = JSONValue.array([.string("a"), .number(1), .bool(false)])
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == value)
    }

    @Test
    func `Object round-trips through Codable`() throws {
        let value = JSONValue.object(["key": .string("value"), "count": .number(3)])
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == value)
    }

    @Test
    func `Nested structure round-trips through Codable`() throws {
        let value = JSONValue.object([
            "name": .string("deploy"),
            "tags": .array([.string("prod"), .string("v2")]),
            "metadata": .object(["retry": .bool(true), "count": .number(3)]),
            "optional": .null,
        ])
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == value)
    }

    // MARK: - parse(_:) helper

    @Test
    func `parse decodes valid JSON object`() {
        let result = JSONValue.parse(#"{"repo":"main","count":5}"#)
        if case let .object(dict) = result {
            #expect(dict["repo"] == .string("main"))
            #expect(dict["count"] == .number(5))
        } else {
            Issue.record("Expected object")
        }
    }

    @Test
    func `parse decodes valid JSON array`() {
        let result = JSONValue.parse("[1,2,3]")
        #expect(result == .array([.number(1), .number(2), .number(3)]))
    }

    @Test
    func `Integer 1 decodes as number not bool`() throws {
        let data = Data("[1, 0, true, false]".utf8)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == .array([.number(1), .number(0), .bool(true), .bool(false)]))
    }

    @Test
    func `parse falls back to string for non-JSON`() {
        let result = JSONValue.parse("just a plain string")
        #expect(result == .string("just a plain string"))
    }

    @Test
    func `parse decodes JSON boolean`() {
        #expect(JSONValue.parse("true") == .bool(true))
        #expect(JSONValue.parse("false") == .bool(false))
    }

    @Test
    func `parse decodes JSON number`() {
        #expect(JSONValue.parse("42") == .number(42))
    }

    @Test
    func `parse decodes JSON null`() {
        #expect(JSONValue.parse("null") == .null)
    }
}
