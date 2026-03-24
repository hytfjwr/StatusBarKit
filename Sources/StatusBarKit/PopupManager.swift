import AppKit

@available(macOS 26, *)
@MainActor
public final class PopupManager {
    public static let shared = PopupManager()
    private weak var activePopup: PopupPanel?

    private init() {}

    public func willShow(_ popup: PopupPanel) {
        if activePopup !== popup {
            activePopup?.hidePopup()
        }
        activePopup = popup
    }

    public func didHide(_ popup: PopupPanel) {
        if activePopup === popup {
            activePopup = nil
        }
    }

    /// Re-apply tint overlay on the active popup, if any.
    public func updateTint() {
        activePopup?.updateTint()
    }
}
