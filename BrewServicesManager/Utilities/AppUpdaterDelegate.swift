//
//  AppUpdaterDelegate.swift
//  BrewServicesManager
//

import Sparkle

/// Delegate for SPUStandardUserDriver that implements gentle update reminders.
/// Allows modal alerts only during initial app launch; uses gentle reminders (icon badge) afterward.
@MainActor
final class AppUpdaterDelegate: NSObject, SPUStandardUserDriverDelegate {
    // MARK: - Properties

    /// Callback to notify AppUpdater when update availability changes.
    /// - Parameter hasUpdate: True when update is available and waiting for user attention.
    var onUpdateAvailabilityChanged: ((Bool) -> Void)?

    /// Callback to notify AppUpdater when user views an update.
    /// Called when user clicks "Check for Updates" and sees the update dialog.
    var onUserViewedUpdate: (() -> Void)?

    /// Tracks if we're in the initial app launch window.
    /// Modal alerts are allowed during this period; afterward, only gentle reminders.
    private var isInitialLaunch = true

    // MARK: - Initialization

    override init() {
        super.init()

        // After 30 seconds, consider initial launch period over.
        // This provides a window for the first auto-check to show a modal if needed.
        Task {
            try? await Task.sleep(for: .seconds(30))
            isInitialLaunch = false
        }
    }

    // MARK: - SPUStandardUserDriverDelegate

    var supportsGentleScheduledUpdateReminders: Bool {
        true
    }

    func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        // Allow Sparkle to show modal alerts only during initial launch window.
        // After that, we handle updates with gentle reminders (icon badge).
        let shouldShowModal = isInitialLaunch

        if isInitialLaunch {
            // First check is done; subsequent checks use gentle reminders
            isInitialLaunch = false
        }

        return shouldShowModal
    }

    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem,
        state: SPUUserUpdateState
    ) {
        // Sparkle will handle showing this update (either modal or gentle reminder)
        // If we're handling it as a gentle reminder, notify AppUpdater to show badge
        if !handleShowingUpdate {
            onUpdateAvailabilityChanged?(true)
        }
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        // User clicked "Check for Updates" and saw the update dialog.
        // Clear the gentle reminder badge since they're now aware of the update.
        onUserViewedUpdate?()
    }

    func standardUserDriverWillFinishUpdateSession() {
        // Update session ending (user dismissed, postponed, or installed).
        // Clear the badge since the update interaction is complete.
        onUpdateAvailabilityChanged?(false)
    }
}
