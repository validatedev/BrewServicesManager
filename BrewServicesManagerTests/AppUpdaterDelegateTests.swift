//
//  AppUpdaterDelegateTests.swift
//  BrewServicesManagerTests
//

import XCTest
import Sparkle
@testable import BrewServicesManager

@MainActor
final class AppUpdaterDelegateTests: XCTestCase {
    var delegate: AppUpdaterDelegate!
    var updateAvailabilityCallbackInvoked = false
    var updateAvailabilityValue: Bool?
    var userViewedCallbackInvoked = false

    override func setUp() async throws {
        delegate = AppUpdaterDelegate()
        updateAvailabilityCallbackInvoked = false
        updateAvailabilityValue = nil
        userViewedCallbackInvoked = false

        delegate.onUpdateAvailabilityChanged = { [weak self] hasUpdate in
            self?.updateAvailabilityCallbackInvoked = true
            self?.updateAvailabilityValue = hasUpdate
        }

        delegate.onUserViewedUpdate = { [weak self] in
            self?.userViewedCallbackInvoked = true
        }
    }

    override func tearDown() async throws {
        delegate = nil
    }

    func testSupportsGentleReminders() {
        XCTAssertTrue(delegate.supportsGentleScheduledUpdateReminders)
    }

    func testInitialLaunchAllowsModal() {
        // First check during initial launch should allow Sparkle to show modal
        let shouldShowModal = delegate.standardUserDriverShouldHandleShowingScheduledUpdate(
            MockAppcastItem(),
            andInImmediateFocus: false
        )

        XCTAssertTrue(shouldShowModal, "First check during initial launch should allow modal")
    }

    func testSubsequentChecksUseGentleReminders() {
        // First check (consumes initial launch flag)
        _ = delegate.standardUserDriverShouldHandleShowingScheduledUpdate(
            MockAppcastItem(),
            andInImmediateFocus: false
        )

        // Second check should use gentle reminders (no modal)
        let shouldShowModal = delegate.standardUserDriverShouldHandleShowingScheduledUpdate(
            MockAppcastItem(),
            andInImmediateFocus: false
        )

        XCTAssertFalse(shouldShowModal, "Subsequent checks should use gentle reminders, not modals")
    }

    func testUpdateAvailabilityCallbackInvokedWithTrue() {
        // When Sparkle won't handle showing update (handleShowingUpdate = false),
        // delegate should notify that update is available
        delegate.standardUserDriverWillHandleShowingUpdate(
            false,
            forUpdate: MockAppcastItem(),
            state: SPUUserUpdateState()
        )

        XCTAssertTrue(updateAvailabilityCallbackInvoked, "Callback should be invoked")
        XCTAssertEqual(updateAvailabilityValue, true, "Callback should indicate update is available")
    }

    func testUpdateAvailabilityNotInvokedWhenSparkleHandles() {
        // When Sparkle will handle showing update (handleShowingUpdate = true),
        // delegate should not invoke callback (Sparkle shows modal, no gentle reminder needed)
        delegate.standardUserDriverWillHandleShowingUpdate(
            true,
            forUpdate: MockAppcastItem(),
            state: SPUUserUpdateState()
        )

        XCTAssertFalse(updateAvailabilityCallbackInvoked, "Callback should not be invoked when Sparkle handles update")
    }

    func testUserViewedCallbackInvoked() {
        delegate.standardUserDriverDidReceiveUserAttention(forUpdate: MockAppcastItem())

        XCTAssertTrue(userViewedCallbackInvoked, "User viewed callback should be invoked")
    }

    func testUpdateSessionFinishClearsAvailability() {
        delegate.standardUserDriverWillFinishUpdateSession()

        XCTAssertTrue(updateAvailabilityCallbackInvoked, "Callback should be invoked on session finish")
        XCTAssertEqual(updateAvailabilityValue, false, "Callback should indicate update is no longer available")
    }

    func testInitialLaunchTimesOut() async throws {
        // First check should allow modal
        let firstCheck = delegate.standardUserDriverShouldHandleShowingScheduledUpdate(
            MockAppcastItem(),
            andInImmediateFocus: false
        )
        XCTAssertTrue(firstCheck, "First check should allow modal")

        // Already used up initial launch flag, so second check should use gentle reminder
        let secondCheck = delegate.standardUserDriverShouldHandleShowingScheduledUpdate(
            MockAppcastItem(),
            andInImmediateFocus: false
        )
        XCTAssertFalse(secondCheck, "Second check should use gentle reminder")
    }
}

// MARK: - Mock SUAppcastItem

/// Minimal mock implementation of SUAppcastItem for testing.
/// SUAppcastItem is an Objective-C class from Sparkle framework.
private class MockAppcastItem: SUAppcastItem {
    init() {
        // SUAppcastItem requires specific initialization
        // For unit tests, we use a minimal mock that satisfies the protocol
        super.init(dictionary: [:], failureReason: nil, relativeToURL: nil)
    }
}
