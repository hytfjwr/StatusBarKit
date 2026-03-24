import Foundation

// MARK: - IPCFraming

/// Utilities for framing IPC messages over a stream socket.
///
/// Wire format: `[4 bytes UInt32 big-endian: body length][JSON body]`
public enum IPCFraming {
    /// Maximum message size (1 MB) to prevent resource exhaustion.
    public static let maxMessageSize: UInt32 = 1_048_576

    /// Encode a `Codable` value into a length-prefixed frame.
    public static func encode(_ value: some Encodable) throws -> Data {
        let body = try JSONEncoder().encode(value)
        guard body.count <= maxMessageSize else {
            throw IPCFramingError.messageTooLarge(body.count)
        }
        var length = UInt32(body.count).bigEndian
        var frame = Data(bytes: &length, count: 4)
        frame.append(body)
        return frame
    }

    /// Read exactly `count` bytes from a file descriptor.
    /// Returns `nil` if the connection was closed before all bytes were read.
    public static func readExact(fd: Int32, count: Int) -> Data? {
        var buffer = Data(count: count)
        var offset = 0
        while offset < count {
            let bytesRead = buffer.withUnsafeMutableBytes { ptr in
                read(fd, ptr.baseAddress!.advanced(by: offset), count - offset)
            }
            if bytesRead <= 0 {
                return nil
            }
            offset += bytesRead
        }
        return buffer
    }

    /// Read a length-prefixed frame from a file descriptor and decode it.
    public static func readFrame<T: Decodable>(fd: Int32, as type: T.Type) throws -> T? {
        guard let header = readExact(fd: fd, count: 4) else {
            return nil
        }
        let length = header.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        guard length > 0, length <= maxMessageSize else {
            throw IPCFramingError.invalidLength(length)
        }
        guard let body = readExact(fd: fd, count: Int(length)) else {
            return nil
        }
        return try JSONDecoder().decode(type, from: body)
    }

    /// Write a length-prefixed frame to a file descriptor.
    public static func writeFrame(fd: Int32, data: Data) -> Bool {
        data.withUnsafeBytes { ptr in
            var offset = 0
            while offset < data.count {
                let written = write(fd, ptr.baseAddress!.advanced(by: offset), data.count - offset)
                if written <= 0 {
                    return false
                }
                offset += written
            }
            return true
        }
    }
}

// MARK: - IPCFramingError

public enum IPCFramingError: Error, Sendable {
    case messageTooLarge(Int)
    case invalidLength(UInt32)
}
