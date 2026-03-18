import Testing
@testable import StatusBarKit

@Suite("GraphDataBuffer")
struct GraphDataBufferTests {
    @Test("Empty buffer")
    @MainActor func emptyBuffer() {
        let buffer = GraphDataBuffer(capacity: 5)
        #expect(buffer.isEmpty)
        #expect(buffer.values() == [])
    }

    @Test("Push and retrieve values")
    @MainActor func pushAndRetrieve() {
        let buffer = GraphDataBuffer(capacity: 5)
        buffer.push(1.0)
        buffer.push(2.0)
        buffer.push(3.0)
        #expect(!buffer.isEmpty)
        #expect(buffer.values() == [1.0, 2.0, 3.0])
    }

    @Test("Fill to capacity")
    @MainActor func fillToCapacity() {
        let buffer = GraphDataBuffer(capacity: 3)
        buffer.push(1.0)
        buffer.push(2.0)
        buffer.push(3.0)
        #expect(buffer.values() == [1.0, 2.0, 3.0])
    }

    @Test("Wraps around when exceeding capacity")
    @MainActor func wrapsAround() {
        let buffer = GraphDataBuffer(capacity: 3)
        buffer.push(1.0)
        buffer.push(2.0)
        buffer.push(3.0)
        buffer.push(4.0) // overwrites 1.0
        #expect(buffer.values() == [2.0, 3.0, 4.0])
    }

    @Test("Multiple wraps maintain order")
    @MainActor func multipleWraps() {
        let buffer = GraphDataBuffer(capacity: 3)
        for i in 1...7 {
            buffer.push(Double(i))
        }
        // Last 3 values: 5, 6, 7
        #expect(buffer.values() == [5.0, 6.0, 7.0])
    }

    @Test("Single capacity buffer")
    @MainActor func singleCapacity() {
        let buffer = GraphDataBuffer(capacity: 1)
        buffer.push(1.0)
        #expect(buffer.values() == [1.0])
        buffer.push(2.0)
        #expect(buffer.values() == [2.0])
    }
}
