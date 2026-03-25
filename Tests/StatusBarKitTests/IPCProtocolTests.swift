import Foundation
import StatusBarKit
import Testing

struct IPCProtocolTests {

    // MARK: - IPCCommand Codable round-trips

    @Test
    func `list command round-trips through Codable`() throws {
        let request = IPCRequest(command: .list)
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(IPCRequest.self, from: data)
        #expect(decoded.command == .list)
        #expect(decoded.version == ipcProtocolVersion)
    }

    @Test
    func `getWidget command round-trips through Codable`() throws {
        let request = IPCRequest(command: .getWidget(id: "battery"))
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(IPCRequest.self, from: data)
        #expect(decoded.command == .getWidget(id: "battery"))
    }

    @Test
    func `setWidget command round-trips through Codable`() throws {
        let cmd = IPCCommand.setWidget(id: "battery", key: "showPercentage", value: .bool(true))
        let request = IPCRequest(command: cmd)
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(IPCRequest.self, from: data)
        #expect(decoded.command == cmd)
    }

    @Test
    func `setGlobal command round-trips through Codable`() throws {
        let cmd = IPCCommand.setGlobal(keyPath: "bar.height", value: .double(44.5))
        let request = IPCRequest(command: cmd)
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(IPCRequest.self, from: data)
        #expect(decoded.command == cmd)
    }

    @Test
    func `reload command round-trips through Codable`() throws {
        let request = IPCRequest(command: .reload)
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(IPCRequest.self, from: data)
        #expect(decoded.command == .reload)
    }

    // MARK: - IPCResponse round-trips

    @Test
    func `Success response with widgetList round-trips`() throws {
        let widget = WidgetInfoDTO(
            id: "cpu",
            displayName: "CPU",
            position: .right,
            sortIndex: 0,
            isVisible: true,
            settings: ["threshold": .int(80)],
        )
        let response = IPCResponse(
            requestID: "test-123",
            result: .success(.widgetList([widget])),
        )
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(IPCResponse.self, from: data)
        #expect(decoded.requestID == "test-123")
        if case let .success(.widgetList(widgets)) = decoded.result {
            #expect(widgets.count == 1)
            #expect(widgets[0].id == "cpu")
            #expect(widgets[0].position == .right)
            #expect(widgets[0].settings["threshold"] == .int(80))
        } else {
            Issue.record("Expected success with widgetList")
        }
    }

    @Test
    func `Success response with ok round-trips`() throws {
        let response = IPCResponse(requestID: "r1", result: .success(.ok))
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(IPCResponse.self, from: data)
        #expect(decoded.result == .success(.ok))
    }

    @Test
    func `Failure response round-trips`() throws {
        let response = IPCResponse(
            requestID: "r1",
            result: .failure(.widgetNotFound(id: "unknown")),
        )
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(IPCResponse.self, from: data)
        #expect(decoded.result == .failure(.widgetNotFound(id: "unknown")))
    }

    @Test
    func `Version mismatch error round-trips`() throws {
        let response = IPCResponse(
            requestID: "r1",
            result: .failure(.versionMismatch(serverVersion: 2, clientVersion: 1)),
        )
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(IPCResponse.self, from: data)
        #expect(decoded.result == .failure(.versionMismatch(serverVersion: 2, clientVersion: 1)))
    }

    // MARK: - IPCFraming

    @Test
    func `IPCFraming encode and decode round-trip`() throws {
        let request = IPCRequest(command: .list)
        let frame = try IPCFraming.encode(request)

        // Verify 4-byte header + JSON body
        #expect(frame.count > 4)
        let length = frame.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        #expect(Int(length) == frame.count - 4)

        // Verify JSON body is decodable
        let body = frame.dropFirst(4)
        let decoded = try JSONDecoder().decode(IPCRequest.self, from: Data(body))
        #expect(decoded.command == .list)
    }

    // MARK: - WidgetInfoDTO

    @Test
    func `WidgetInfoDTO with empty settings round-trips`() throws {
        let dto = WidgetInfoDTO(
            id: "time",
            displayName: "Time",
            position: .right,
            sortIndex: 12,
            isVisible: true,
            settings: [:],
        )
        let data = try JSONEncoder().encode(dto)
        let decoded = try JSONDecoder().decode(WidgetInfoDTO.self, from: data)
        #expect(decoded == dto)
    }

    @Test
    func `WidgetInfoDTO with mixed ConfigValue types round-trips`() throws {
        let dto = WidgetInfoDTO(
            id: "network",
            displayName: "Network",
            position: .right,
            sortIndex: 5,
            isVisible: false,
            settings: [
                "interval": .int(5),
                "showUpload": .bool(true),
                "label": .string("Net"),
                "opacity": .double(0.8),
            ],
        )
        let data = try JSONEncoder().encode(dto)
        let decoded = try JSONDecoder().decode(WidgetInfoDTO.self, from: data)
        #expect(decoded == dto)
    }
}
