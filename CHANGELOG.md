# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Automatic update support via Sparkle framework
- "Check for Updates" option in Settings
- Toggle for automatic update checks
- Port detection for running services using `lsof`
- User-configurable service links with custom URLs
- Auto-suggest URLs based on detected listening ports
- Inline link buttons in service rows

### Changed

- Refactored menu bar views into single-view files
- Hardened actor isolation for safer Swift concurrency
- Removed hardcoded development team IDs for open source contributions

### Fixed

- System authentication dialog now properly receives mouse input in MenuBarExtra context
- Privilege escalation uses NSAppleScript API on MainActor for reliable dialog interaction
- Data race in ServiceLinksStore with serialized disk writes
- Child process detection using pgrep instead of ps -g
- Port numbers display without thousands separators
- Port detection triggers when actions popover opens

## [1.0.0] - 2024-12-25

### Added

- Initial release
- Menu bar interface for managing Homebrew services
- Support for user and system service domains
- Service status monitoring with auto-refresh
- Start, stop, and restart service actions
- Detailed service information view
- Debug mode for verbose Homebrew output

[unreleased]: https://github.com/validatedev/BrewServicesManager/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/validatedev/BrewServicesManager/releases/tag/v1.0.0
