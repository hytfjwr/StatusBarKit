@testable import StatusBarKit
import Testing

struct GraphDataBufferTests {
    @Test
    @MainActor
    func `Empty buffer`() {
        let buffer = GraphDataBuffer(capacity: 5)
        #expect(buffer.isEmpty)
        #expect(buffer.values() == [])
    }

    @Test
    @MainActor
    func `Push and retrieve values`() {
        let buffer = GraphDataBuffer(capacity: 5)
        buffer.push(1.0)
        buffer.push(2.0)
        buffer.push(3.0)
        #expect(!buffer.isEmpty)
        #expect(buffer.values() == [1.0, 2.0, 3.0])
    }

    @Test
    @MainActor
    func `Fill to capacity`() {
        let buffer = GraphDataBuffer(capacity: 3)
        buffer.push(1.0)
        buffer.push(2.0)
        buffer.push(3.0)
        #expect(buffer.values() == [1.0, 2.0, 3.0])
    }

    @Test
    @MainActor
    func `Wraps around when exceeding capacity`() {
        let buffer = GraphDataBuffer(capacity: 3)
        buffer.push(1.0)
        buffer.push(2.0)
        buffer.push(3.0)
        buffer.push(4.0) // overwrites 1.0
        #expect(buffer.values() == [2.0, 3.0, 4.0])
    }

    @Test
    @MainActor
    func `Multiple wraps maintain order`() {
        let buffer = GraphDataBuffer(capacity: 3)
        for i in 1 ... 7 {
            buffer.push(Double(i))
        }
        // Last 3 values: 5, 6, 7
        #expect(buffer.values() == [5.0, 6.0, 7.0])
    }

    @Test
    @MainActor
    func `Single capacity buffer`() {
        let buffer = GraphDataBuffer(capacity: 1)
        buffer.push(1.0)
        #expect(buffer.values() == [1.0])
        buffer.push(2.0)
        #expect(buffer.values() == [2.0])
    }
}
