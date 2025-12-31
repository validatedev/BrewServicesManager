import Foundation

enum ServiceLinksManagementRoute: Equatable {
    case list
    case add
    case edit(ServiceLink)
}
