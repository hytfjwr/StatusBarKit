import Foundation
import StatusBarIPC

// MARK: - ToastService

/// Plugin-facing API for posting toast notifications.
///
/// The host application calls `configure(handler:)` at startup to wire in the
/// actual `ToastManager`. Plugins call `post(_:)` without depending on the main app target.
@MainActor
public final class ToastService {
    public static let shared = ToastService()

    private var postHandler: (@MainActor (ToastRequest) -> String)?

    private init() {}

    /// Called once by the host app at startup to wire in the actual implementation.
    public func configure(handler: @escaping @MainActor (ToastRequest) -> String) {
        postHandler = handler
    }

    /// Post a toast notification. Returns the assigned toast ID.
    @discardableResult
    public func post(_ request: ToastRequest) -> String {
        guard let postHandler else {
            assertionFailure("ToastService.configure(handler:) must be called before post(_:)")
            return ""
        }
        return postHandler(request)
    }
}
