import SwiftUI

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
    /// Preferred size for the settings sheet. Return `nil` to use the default (360 × 240).
    var preferredSettingsSize: CGSize? { get }
    /// Called when the widget becomes active. Use this to start timers or subscriptions.
    func start()
    /// Called when the widget is deactivated. Use this to cancel timers and release resources.
    func stop()
    /// The widget's main view rendered in the status bar.
    @ViewBuilder
    func body() -> WidgetBody
    /// Optional settings view shown when the user clicks the gear icon in preferences.
    @ViewBuilder
    func settingsBody() -> SettingsBody
}

public extension StatusBarWidget {
    var sfSymbolName: String {
        "square.dashed"
    }

    var preferredSettingsSize: CGSize? {
        nil
    }
}

public extension StatusBarWidget where SettingsBody == EmptyView {
    func settingsBody() -> EmptyView {
        EmptyView()
    }
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
    public let preferredSettingsSize: CGSize?
    private let _start: @MainActor () -> Void
    private let _stop: @MainActor () -> Void
    private let _body: @MainActor () -> AnyView
    private let _settingsBody: @MainActor () -> AnyView

    public init<W: StatusBarWidget>(_ widget: W) {
        id = widget.id
        position = widget.position
        updateInterval = widget.updateInterval
        sfSymbolName = widget.sfSymbolName
        hasSettings = W.SettingsBody.self != EmptyView.self
        preferredSettingsSize = widget.preferredSettingsSize
        _start = { widget.start() }
        _stop = { widget.stop() }
        _body = { AnyView(widget.body()) }
        _settingsBody = { AnyView(widget.settingsBody()) }
    }

    /// Forward `start()` to the wrapped widget.
    public func start() {
        _start()
    }

    /// Forward `stop()` to the wrapped widget.
    public func stop() {
        _stop()
    }

    /// Return the widget's body as a type-erased `AnyView`.
    public func body() -> AnyView {
        _body()
    }

    /// Return the widget's settings view as a type-erased `AnyView`.
    public func settingsBody() -> AnyView {
        _settingsBody()
    }
}
