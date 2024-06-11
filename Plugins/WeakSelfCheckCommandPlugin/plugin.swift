//
//  plugin.swift
//
//
//  Created by p-x9 on 2024/06/07
//
//

import Foundation
import PackagePlugin

@main
struct WeakSelfCheckCommandPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        try performCommand(
            packageDirectory: context.package.directory,
            tool: try context.tool(named: "weak-self-check"),
            arguments: arguments
        )
    }

    private func performCommand(
        packageDirectory: Path,
        tool: PluginContext.Tool,
        arguments: [String]
    ) throws {
        var argumentExtractor = ArgumentExtractor(arguments)
        let reportType = argumentExtractor.extractOption(named: "report-type").first ?? "error"
        let silent = argumentExtractor.extractFlag(named: "silent")
        let config = argumentExtractor.extractOption(named: "config").first
        ?? packageDirectory.firstConfigurationFileInParentDirectories()?.string ?? ""
        let indexStorePath = argumentExtractor.extractOption(named: "index-store-path").first
        let _ = argumentExtractor.extractOption(named: "target")
        let path = argumentExtractor.remainingArguments.first ?? packageDirectory.string

        let process = Process()
        process.launchPath = tool.path.string
        process.arguments = [
            path,
            "--config",
            config,
            "--report-type",
            reportType
        ]

        if (silent != 0) {
            process.arguments?.append("--silent")
        }

        if let indexStorePath {
            process.arguments? += [
                "--index-store-path",
                indexStorePath
            ]
        }

        try process.run()
        process.waitUntilExit()
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension WeakSelfCheckCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        try performCommand(
            packageDirectory: context.xcodeProject.directory,
            tool: try context.tool(named: "weak-self-check"),
            arguments: arguments
        )
    }
}
#endif

// ref: https://github.com/realm/SwiftLint/blob/main/Plugins/SwiftLintPlugin/Path%2BHelpers.swift
extension Path {
    func firstConfigurationFileInParentDirectories() -> Path? {
        let defaultConfigurationFileNames = [
            ".swift-weak-self-check.yml"
        ]
        let proposedDirectories = sequence(
            first: self,
            next: { path in
                guard path.stem.count > 1 else {
                    // Check we're not at the root of this filesystem, as `removingLastComponent()`
                    // will continually return the root from itself.
                    return nil
                }

                return path.removingLastComponent()
            }
        )

        for proposedDirectory in proposedDirectories {
            for fileName in defaultConfigurationFileNames {
                let potentialConfigurationFile = proposedDirectory.appending(subpath: fileName)
                if potentialConfigurationFile.isAccessible() {
                    return potentialConfigurationFile
                }
            }
        }
        return nil
    }

    /// Safe way to check if the file is accessible from within the current process sandbox.
    private func isAccessible() -> Bool {
        let result = string.withCString { pointer in
            access(pointer, R_OK)
        }

        return result == 0
    }
}
