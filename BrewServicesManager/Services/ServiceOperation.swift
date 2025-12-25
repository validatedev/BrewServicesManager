import Foundation

struct ServiceOperation: Sendable {
    var status: ServiceOperationStatus
    var action: ServiceAction?
    var error: AppError?
    var diagnostics: String?

    static let idle = ServiceOperation(status: .idle, action: nil, error: nil, diagnostics: nil)
}

extension ServiceOperation {
    static func diagnostics(for error: AppError) -> String? {
        switch error {
        case .jsonDecodingFailed(let rawOutput, _):
            rawOutput
        case .brewFailed(let exitCode, let stderr):
            "Exit code: \(exitCode)\n\n\(stderr)"
        default:
            error.localizedDescription
        }
    }
}
