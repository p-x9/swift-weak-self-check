import Foundation
import ArgumentParser
import WeakSelfCheckCore

struct weak_self_check: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "weak-self-check",
        abstract: "Check whether `self` is captured by weak reference in Closure.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    @Option(
        help: "Path"
    )
    var path: String?

    mutating func run() throws {
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
        print("[weak self check] checking: \(url.lastPathComponent)")

        let checker = WeakSelfChecker(fileName: url.path)
        try checker.diagnose()
    }
}

weak_self_check.main()
