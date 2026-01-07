import Foundation

enum MenuBarRoute: Hashable {
    case main
    case settings
    case serviceInfo(String)
    case manageLinks(service: String, ports: [ServicePort])
}
