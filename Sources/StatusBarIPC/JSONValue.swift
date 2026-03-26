import Foundation

/// A type-safe representation of arbitrary JSON values.
/// Used for plugin event payloads transmitted over IPC.
public enum JSONValue: Sendable, Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([Self])
    case object([String: Self])

    // MARK: - Codable

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let v = try? container.decode(Double.self) {
            // Double before Bool: unlike ConfigValue (YAML scalars), JSON integer
            // tokens must stay numeric. This order is safe because JSONDecoder does
            // not decode true/false tokens as Double.
            self = .number(v)
        } else if let v = try? container.decode(Bool.self) {
            self = .bool(v)
        } else if let v = try? container.decode(String.self) {
            self = .string(v)
        } else if let v = try? container.decode([Self].self) {
            self = .array(v)
        } else if let v = try? container.decode([String: Self].self) {
            self = .object(v)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Unsupported JSON value type"
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(v): try container.encode(v)
        case let .number(v): try container.encode(v)
        case let .bool(v): try container.encode(v)
        case .null: try container.encodeNil()
        case let .array(v): try container.encode(v)
        case let .object(v): try container.encode(v)
        }
    }

    // MARK: - Parsing helper

    /// Parse a raw string as a `JSONValue`.
    /// Attempts JSON decoding first; falls back to `.string(rawString)`.
    public static func parse(_ rawString: String) -> Self {
        guard let data = rawString.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return .string(rawString)
        }
        return value
    }
}
