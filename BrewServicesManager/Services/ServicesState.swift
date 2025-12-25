import Foundation

enum ServicesState: Sendable {
    case idle
    case loading
    case refreshing([BrewServiceListEntry])
    case loaded([BrewServiceListEntry])
    case error(AppError)
}
