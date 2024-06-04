import Foundation
import ArgumentParser
import Yams
import WeakSelfCheckCore

struct weak_self_check: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "weak-self-check",
        abstract: "Check whether `self` is captured by weak reference in Closure.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    @Option(
        help: "Path",
        completion: .directory
    )
    var path: String?

    @Argument(help: "Detected as `error` or `warning` [default: error]")
    var reportType: ReportType?

    @Flag(name: .customLong("silent"), help: "Do not output logs")
    var silent: Bool = false

    @Option(
        help: "Config",
        completion: .file(extensions: ["yml", "yaml"])
    )
    var config: String = ".swift-weak-self-check.yml"

    var whiteList: [WhiteListElement] = []

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
    private func check(forDirectory url: URL) throws {
        let fileManager: FileManager = .default

        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil
        )
        try contents
            .forEach {
                if $0.pathExtension == "swift" {
                    try check(forFile: $0)
                } else if fileManager.isDirectory($0) {
                    try check(forDirectory: $0)
                }
            }
    }

    private func check(forFile url: URL) throws {
        guard url.pathExtension == "swift" else { return }
        if !silent {
            print("[weak self check] checking: \(url.relativePath)")
        }

        let checker = WeakSelfChecker(
            fileName: url.path,
            reportType: reportType ?? .error,
            whiteList: whiteList
        )
        try checker.diagnose()
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

        self.whiteList = config.whiteList

        if config.slent {
            self.silent = true
        }
        if reportType == nil {
            self.reportType = config.reportType
        }
    }
}

weak_self_check.main()
