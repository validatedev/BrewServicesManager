import Foundation

enum MenuBarRoute: Hashable {
    case main
    case settings
    case serviceInfo(BrewServiceInfoEntry)
    case manageLinks(service: String, ports: [ServicePort])
}
