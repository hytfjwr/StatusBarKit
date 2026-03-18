import SwiftUI

// MARK: - WidgetPosition

@frozen public enum WidgetPosition: String, Codable, CaseIterable, Sendable {
    case left
    case center
    case right
}

// MARK: - StatusBarWidget

@MainActor
public protocol StatusBarWidget: AnyObject {
    associatedtype WidgetBody: View
    associatedtype SettingsBody: View = EmptyView
    /// Unique identifier for this widget (e.g. "cpu", "weather").
    var id: String { get }
    /// The bar section where this widget appears.
    var position: WidgetPosition { get }
    /// Polling interval in seconds. Return `nil` to disable automatic refresh.
    var updateInterval: TimeInterval? { get }
    /// SF Symbol name used in the preferences widget list.
    var sfSymbolName: String { get }
    /// Called when the widget becomes active. Use this to start timers or subscriptions.
    func start()
    /// Called when the widget is deactivated. Use this to cancel timers and release resources.
    func stop()
    /// The widget's main view rendered in the status bar.
    @ViewBuilder func body() -> WidgetBody
    /// Optional settings view shown when the user clicks the gear icon in preferences.
    @ViewBuilder func settingsBody() -> SettingsBody
}

extension StatusBarWidget {
    public var sfSymbolName: String { "square.dashed" }
}

extension StatusBarWidget where SettingsBody == EmptyView {
    public func settingsBody() -> EmptyView { EmptyView() }
}

// MARK: - AnyStatusBarWidget

/// Type-erased wrapper for StatusBarWidget.
/// Centralizes the AnyView conversion so individual widgets return concrete View types,
/// enabling SwiftUI's structural diffing within each widget subtree.
@MainActor
public struct AnyStatusBarWidget: Identifiable {
    public let id: String
    public let position: WidgetPosition
    public let updateInterval: TimeInterval?
    public let sfSymbolName: String
    public let hasSettings: Bool
    private let _start: @MainActor () -> Void
    private let _stop: @MainActor () -> Void
    private let _body: @MainActor () -> AnyView
    private let _settingsBody: @MainActor () -> AnyView

    public init<W: StatusBarWidget>(_ widget: W) {
        self.id = widget.id
        self.position = widget.position
        self.updateInterval = widget.updateInterval
        self.sfSymbolName = widget.sfSymbolName
        self.hasSettings = W.SettingsBody.self != EmptyView.self
        self._start = { widget.start() }
        self._stop = { widget.stop() }
        self._body = { AnyView(widget.body()) }
        self._settingsBody = { AnyView(widget.settingsBody()) }
    }

    /// Forward `start()` to the wrapped widget.
    public func start() { _start() }
    /// Forward `stop()` to the wrapped widget.
    public func stop() { _stop() }
    /// Return the widget's body as a type-erased `AnyView`.
    public func body() -> AnyView { _body() }
    /// Return the widget's settings view as a type-erased `AnyView`.
    public func settingsBody() -> AnyView { _settingsBody() }
}
