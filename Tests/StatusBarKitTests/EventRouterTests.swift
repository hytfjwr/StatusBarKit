@testable import StatusBarKit
import SwiftUI
import Testing

// MARK: - EventCapturingWidget

@MainActor
private final class EventCapturingWidget: StatusBarWidget {
    let id: String
    let position = WidgetPosition.left
    let updateInterval: TimeInterval? = nil
    let subscribedEvents: [String]
    private(set) var receivedEvents: [PluginEvent] = []

    init(id: String, subscribedEvents: [String]) {
        self.id = id
        self.subscribedEvents = subscribedEvents
    }

    func start() {}
    func stop() {}
    func body() -> some View {
        Text("test")
    }

    func handleEvent(_ event: PluginEvent) {
        receivedEvents.append(event)
    }
}

// MARK: - EventRouterTests

struct EventRouterTests {

    private let pluginID = "com.example.myapp"

    @Test
    @MainActor
    func `Exact match routes event to widget`() {
        let widget = EventCapturingWidget(id: "w1", subscribedEvents: ["deploy_finished"])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(widget)], pluginID: pluginID)

        let event = PluginEvent(name: "com.example.myapp.deploy_finished")
        router.route(event)

        #expect(widget.receivedEvents.count == 1)
        #expect(widget.receivedEvents[0].name == "com.example.myapp.deploy_finished")
    }

    @Test
    @MainActor
    func `Non-matching event is not routed`() {
        let widget = EventCapturingWidget(id: "w1", subscribedEvents: ["deploy_finished"])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(widget)], pluginID: pluginID)

        let event = PluginEvent(name: "com.example.myapp.build_started")
        router.route(event)

        #expect(widget.receivedEvents.isEmpty)
    }

    @Test
    @MainActor
    func `Wildcard suffix matches prefix`() {
        let widget = EventCapturingWidget(id: "w1", subscribedEvents: ["deploy_*"])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(widget)], pluginID: pluginID)

        router.route(PluginEvent(name: "com.example.myapp.deploy_finished"))
        router.route(PluginEvent(name: "com.example.myapp.deploy_started"))
        router.route(PluginEvent(name: "com.example.myapp.build_finished"))

        #expect(widget.receivedEvents.count == 2)
    }

    @Test
    @MainActor
    func `Star-only wildcard matches all events for plugin`() {
        let widget = EventCapturingWidget(id: "w1", subscribedEvents: ["*"])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(widget)], pluginID: pluginID)

        router.route(PluginEvent(name: "com.example.myapp.anything"))
        router.route(PluginEvent(name: "com.example.myapp.something_else"))
        router.route(PluginEvent(name: "com.other.plugin.event"))

        #expect(widget.receivedEvents.count == 2)
    }

    @Test
    @MainActor
    func `Multiple widgets receive same event`() {
        let w1 = EventCapturingWidget(id: "w1", subscribedEvents: ["deploy_finished"])
        let w2 = EventCapturingWidget(id: "w2", subscribedEvents: ["deploy_*"])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(w1), AnyStatusBarWidget(w2)], pluginID: pluginID)

        router.route(PluginEvent(name: "com.example.myapp.deploy_finished"))

        #expect(w1.receivedEvents.count == 1)
        #expect(w2.receivedEvents.count == 1)
    }

    @Test
    @MainActor
    func `Widget with empty subscribedEvents is not registered`() {
        let widget = EventCapturingWidget(id: "w1", subscribedEvents: [])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(widget)], pluginID: pluginID)

        #expect(router.subscriptionCount == 0)
    }

    @Test
    @MainActor
    func `unregisterPlugin removes all subscriptions for that plugin`() {
        let widget = EventCapturingWidget(id: "w1", subscribedEvents: ["event_a", "event_b"])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(widget)], pluginID: pluginID)
        #expect(router.subscriptionCount == 2)

        router.unregisterPlugin(pluginID)
        #expect(router.subscriptionCount == 0)

        router.route(PluginEvent(name: "com.example.myapp.event_a"))
        #expect(widget.receivedEvents.isEmpty)
    }

    @Test
    @MainActor
    func `Multiple plugins are routed independently`() {
        let w1 = EventCapturingWidget(id: "w1", subscribedEvents: ["ping"])
        let w2 = EventCapturingWidget(id: "w2", subscribedEvents: ["ping"])
        let router = EventRouter()
        router.registerWidgets([AnyStatusBarWidget(w1)], pluginID: "com.alpha")
        router.registerWidgets([AnyStatusBarWidget(w2)], pluginID: "com.beta")

        router.route(PluginEvent(name: "com.alpha.ping"))

        #expect(w1.receivedEvents.count == 1)
        #expect(w2.receivedEvents.isEmpty)
    }
}
