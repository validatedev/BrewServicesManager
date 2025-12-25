import Foundation

/// Errors that can occur when locating Homebrew.
enum BrewLocatorError: Error, LocalizedError {
    case brewNotFound

    var errorDescription: String? {
        switch self {
        case .brewNotFound:
            "Homebrew is not installed or could not be found. Please install Homebrew from https://brew.sh"
        }
    }
}
