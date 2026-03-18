@testable import StatusBarKit
import SwiftUI
import Testing

// MARK: - MinimalWidget

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

    func start() {
        started = true
    }

    func stop() {
        stopped = true
    }

    func body() -> some View {
        Text("body")
    }
    // Uses default EmptyView settingsBody and default sfSymbolName
}

// MARK: - WidgetWithSettings

@MainActor
private final class WidgetWithSettings: StatusBarWidget {
    let id = "settings-widget"
    let position = WidgetPosition.right
    let updateInterval: TimeInterval? = 10
    let sfSymbolName = "gear"

    func start() {}
    func stop() {}
    func body() -> some View {
        Text("body")
    }

    func settingsBody() -> some View {
        Text("settings")
    }
}

// MARK: - AnyStatusBarWidgetTests

struct AnyStatusBarWidgetTests {
    @Test
    @MainActor
    func `Properties are forwarded from wrapped widget`() {
        let widget = MinimalWidget(id: "cpu", position: .center, updateInterval: 5.0)
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.id == "cpu")
        #expect(erased.position == .center)
        #expect(erased.updateInterval == 5.0)
    }

    @Test
    @MainActor
    func `hasSettings is false when SettingsBody is EmptyView`() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.hasSettings == false)
    }

    @Test
    @MainActor
    func `hasSettings is true when SettingsBody is custom view`() {
        let widget = WidgetWithSettings()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.hasSettings == true)
    }

    @Test
    @MainActor
    func `start() is forwarded to wrapped widget`() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        erased.start()

        #expect(widget.started == true)
    }

    @Test
    @MainActor
    func `stop() is forwarded to wrapped widget`() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        erased.stop()

        #expect(widget.stopped == true)
    }

    @Test
    @MainActor
    func `Default sfSymbolName is forwarded`() {
        let widget = MinimalWidget()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.sfSymbolName == "square.dashed")
    }

    @Test
    @MainActor
    func `Custom sfSymbolName is forwarded`() {
        let widget = WidgetWithSettings()
        let erased = AnyStatusBarWidget(widget)

        #expect(erased.sfSymbolName == "gear")
    }
}
