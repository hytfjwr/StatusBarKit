import Foundation

@MainActor
public final class GraphDataBuffer {
    private var buffer: [Double]
    private var index: Int = 0
    private let capacity: Int
    private var count: Int = 0

    /// Creates a new buffer with the given capacity. Defaults to 50 data points.
    public init(capacity: Int = 50) {
        self.capacity = capacity
        buffer = Array(repeating: 0, count: capacity)
    }

    public var isEmpty: Bool {
        count == 0 // swiftlint:disable:this empty_count
    }

    /// Append a value to the buffer. Overwrites the oldest entry when full.
    public func push(_ value: Double) {
        buffer[index] = value
        index = (index + 1) % capacity
        if count < capacity {
            count += 1
        }
    }

    /// Returns all buffered values in chronological order (oldest first).
    public func values() -> [Double] {
        guard !isEmpty else {
            return []
        }
        if count < capacity {
            return Array(buffer[0 ..< count])
        }
        return Array(buffer[index ..< capacity]) + Array(buffer[0 ..< index])
    }
}
