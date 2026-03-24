import Foundation

/// A type-erased value for widget configuration. Encodes/decodes as a raw YAML scalar.
public enum ConfigValue: Codable, Sendable, Equatable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Order matters: Bool before Int (YAML `true`/`false`), Int before Double
        if let v = try? container.decode(Bool.self) {
            self = .bool(v)
        } else if let v = try? container.decode(Int.self) {
            self = .int(v)
        } else if let v = try? container.decode(Double.self) {
            self = .double(v)
        } else if let v = try? container.decode(String.self) {
            self = .string(v)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Unsupported config value type",
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(v): try container.encode(v)
        case let .bool(v): try container.encode(v)
        case let .int(v): try container.encode(v)
        case let .double(v): try container.encode(v)
        }
    }

    /// Convenience accessors
    public var stringValue: String? {
        if case let .string(v) = self {
            v
        } else {
            nil
        }
    }

    public var boolValue: Bool? {
        if case let .bool(v) = self {
            v
        } else {
            nil
        }
    }

    public var intValue: Int? {
        if case let .int(v) = self {
            v
        } else {
            nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case let .double(v): v
        case let .int(v): Double(v)
        default: nil
        }
    }
}
