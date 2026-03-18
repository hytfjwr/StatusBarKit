import SwiftUI
import Testing
@testable import StatusBarKit

// MARK: - Mocks

@MainActor
private final class MinimalWidget: StatusBarWidget {
    let id: String
    let position: WidgetPosition
    let updateInterval: TimeInterval?
    private(set) var started = false
    private(set) var stopped = false

    init(id: String = "test", position: WidgetPosition = .left, updateInterval: TimeInterval? = nil) {
        self.id = id
        self.position = position
        self.updateInterval = updateInterval
    }

    func start() { started = true }
    func stop() { stopped = true }
    func body() -> some View { Text("body") }
    // Uses default EmptyView settingsBody and default sfSymbolName
}

@MainActor
private final class WidgetWithSettings: StatusBarWidget {
    let id = "settings-widget"
    let position = WidgetPosition.right
    let updateInterval: TimeInterval? = 10
    let sfSymbolName = "gear"

    func start() {}
    func stop() {}
    func body() -> some View { Text("body") }
    func settingsBody() -> some View { Text("settings") }
}

// MARK: - Tests

@Suite("AnyStatusBarWidget")
struct AnyStatusBarWidgetTests {
    @Test("Properties are forwarded from wrapped widget")
    @MainActor func propertyForwarding() {
        let widget = MinimalWidget(id: "cpu", position: .center, updateInterval: 5.0)
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.id == "cpu")
        #expect(erased.position == .center)
        #expect(erased.updateInterval == 5.0)
    }

    @Test("hasSettings is false when SettingsBody is EmptyView")
    @MainActor func hasSettingsFalse() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.hasSettings == false)
    }

    @Test("hasSettings is true when SettingsBody is custom view")
    @MainActor func hasSettingsTrue() {
        let widget = WidgetWithSettings()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.hasSettings == true)
    }

    @Test("start() is forwarded to wrapped widget")
    @MainActor func startForwarded() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        erased.start()

        #expect(widget.started == true)
    }

    @Test("stop() is forwarded to wrapped widget")
    @MainActor func stopForwarded() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        erased.stop()

        #expect(widget.stopped == true)
    }

    @Test("Default sfSymbolName is forwarded")
    @MainActor func defaultSFSymbol() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.sfSymbolName == "square.dashed")
    }

    @Test("Custom sfSymbolName is forwarded")
    @MainActor func customSFSymbol() {
        let widget = WidgetWithSettings()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.sfSymbolName == "gear")
    }
}
