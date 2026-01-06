import Foundation

nonisolated enum BrewServicesArgumentsBuilder {
    static func listArguments(debugMode: Bool) -> [String] {
        var arguments = ["services", "list", "--json"]
        if debugMode {
            arguments.append("--debug")
        }
        return arguments
    }

    static func infoArguments(serviceName: String, debugMode: Bool) -> [String] {
        var arguments = ["services", "info", serviceName, "--json"]
        if debugMode {
            arguments.append("--debug")
        }
        return arguments
    }

    static func cleanupArguments(debugMode: Bool) -> [String] {
        var arguments = ["services", "cleanup"]
        if debugMode {
            arguments.append("--debug")
        }
        return arguments
    }

    static func serviceActionArguments(action: ServiceAction, serviceName: String, debugMode: Bool) -> [String] {
        var arguments = ["services", action.subcommand, serviceName]
        arguments.append(contentsOf: action.additionalArguments)
        if debugMode {
            arguments.append("--debug")
        }
        return arguments
    }

    static func allActionArguments(action: ServiceAction, debugMode: Bool) -> [String] {
        var arguments = ["services", action.subcommand, "--all"]
        arguments.append(contentsOf: action.additionalArguments)
        if debugMode {
            arguments.append("--debug")
        }
        return arguments
    }
}
