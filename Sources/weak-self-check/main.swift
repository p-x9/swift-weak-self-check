import Foundation
import ArgumentParser
import Yams
import SwiftIndexStore
import WeakSelfCheckCore

struct weak_self_check: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "weak-self-check",
        abstract: "Check whether `self` is captured by weak reference in Closure.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    @Argument(
        help: "Path",
        completion: .directory
    )
    var path: String?

    @Option(help: "Detected as `error` or `warning` (default: error)")
    var reportType: ReportType?

    @Flag(name: .customLong("silent"), help: "Do not output logs")
    var silent: Bool = false

    @Option(
        help: "Config",
        completion: .file(extensions: ["yml", "yaml"])
    )
    var config: String = ".swift-weak-self-check.yml"

    @Option(
        help: "Path for IndexStore",
        completion: .directory
    )
    var indexStorePath: String?

    var whiteList: [WhiteListElement] = []
    var excludedFiles: [String] = []

    lazy var indexStore: IndexStore? = {
        if let indexStorePath = indexStorePath ?? environmentIndexStorePath,
           FileManager.default.fileExists(atPath: indexStorePath) {
            let url = URL(fileURLWithPath: indexStorePath)
            return try? .open(store: url, lib: .open())
        } else {
            return nil
        }
    }()

    mutating func run() throws {
        try readConfig()

        let path = self.path ?? FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: path)

        if FileManager.default.isDirectory(url) {
            try check(forDirectory: url)
        } else {
            try check(forFile: url)
        }
    }
}

extension weak_self_check {
    private mutating func check(forDirectory url: URL) throws {
        let fileManager: FileManager = .default

        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil
        )
        try? contents
            .forEach {
                if $0.pathExtension == "swift" {
                    try check(forFile: $0)
                } else if fileManager.isDirectory($0) {
                    try check(forDirectory: $0)
                }
            }
    }

    private mutating func check(forFile url: URL) throws {
        guard url.pathExtension == "swift" else { return }
        guard !excludedFiles.contains(where: { url.path.matches(pattern: $0) }) else {
            return
        }
        if !silent {
            print("[weak self check] checking: \(url.relativePath)")
        }

        let checker = WeakSelfChecker(
            fileName: url.path,
            reportType: reportType ?? .error,
            whiteList: whiteList,
            indexStore: indexStore
        )
        try? checker.diagnose()
    }
}

extension weak_self_check {
    private mutating func readConfig() throws {
        guard FileManager.default.fileExists(atPath: config) else {
            return
        }
        let url = URL(fileURLWithPath: config)
        let decoder = YAMLDecoder()

        let data = try Data(contentsOf: url)
        let config = try decoder.decode(Config.self, from: data)

        self.whiteList = config.whiteList ?? []
        self.excludedFiles = config.excludedFiles ?? []

        if let slient = config.slent, slient {
            self.silent = true
        }
        if reportType == nil {
            self.reportType = config.reportType
        }
    }
}

extension weak_self_check {
    var environmentIndexStorePath: String? {
        let environment = ProcessInfo.processInfo.environment
        guard let buildDir = environment["BUILD_DIR"] else { return nil }
        let url = URL(fileURLWithPath: buildDir)
        return url
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Index.noindex/DataStore/")
            .path()
    }
}

weak_self_check.main()
