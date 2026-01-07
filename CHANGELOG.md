# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.6] - 2026-01-08

### Changed

- Service Info panel now opens instantly with a loading state instead of blocking on data fetch
- Removed pulsing animation from status indicators for improved performance

## [1.1.5] - 2026-01-07

### Changed

- Renamed app from "BrewServicesManager" to "Brew Services Manager"

## [1.1.4] - 2026-01-07

### Added

- Launch at Login option in Settings

## [1.1.3] - 2026-01-04

### Added

- Gentle update reminders with menu bar icon badge instead of intrusive modal alerts


### Changed

- Extended macOS support to all Sequoia versions

## [1.1.2] - 2026-01-01

### Changed

- Release script updates and stages the Homebrew cask before tagging releases
- Homebrew cask automation now uses the Casks directory as the single source of truth

### Removed

- Duplicate root-level Homebrew cask file

## [1.1.1] - 2026-01-01

### Added

- App version and build number display in Settings
- Homebrew installation option in the README
- Homebrew cask update and PR helpers in the release script

## [1.1.0] - 2026-01-01

### Added

- Automatic update support via Sparkle framework
- Port detection for running services using `lsof`
- User-configurable service links with custom URLs
- Auto-suggest URLs based on detected listening ports
- Inline link buttons in service rows

### Changed

- Refactored menu bar views and navigation
- Improved concurrency with hardened actor isolation and off-main-actor loading
- Switched to LazyVStack in menu views

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

[unreleased]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.6...HEAD
[1.1.6]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.5...v1.1.6
[1.1.5]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/validatedev/BrewServicesManager/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/validatedev/BrewServicesManager/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/validatedev/BrewServicesManager/releases/tag/v1.0.0
