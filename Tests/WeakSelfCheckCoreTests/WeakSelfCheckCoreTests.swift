//
//  WeakSelfCheckCoreTests.swift
//  swift-weak-self-check
//
//  Created by p-x9 on 2025/04/20
//  
//

import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
@testable import WeakSelfCheckCore

final class WeakSelfCheckCoreTests: XCTestCase {
    let defaultMessage = "Use `[weak self]` to avoid memory leaks"
}

extension WeakSelfCheckCoreTests {
    func testMethodArgumentInClass() throws {
        let source = """
        class MyViewController: UIViewController {
            func fetchData() {
                DispatchQueue.global().async {
                    print(self.view)
                }
            }
        }
        """
        try checkReports(
            source: source,
            expectedReports: [
                .init(
                    position: .init(
                        file: #fileID,
                        line: 3,
                        character: 38
                    ),
                    type: .error,
                    content: defaultMessage
                )
            ]
        )

        let source2 = """
        class MyViewController: UIViewController {
            func fetchData() {
                DispatchQueue.global().async { [weak self] in
                    print(self!.view)
                }
            }
        }
        """
        try checkReports(
            source: source2,
            expectedReports: []
        )

        let source3 = """
        class MyViewController: UIViewController {
            func fetchData() {
                DispatchQueue.global().async { [unowned self] in
                    print(self!.view)
                }
            }
        }
        """
        try checkReports(
            source: source3,
            expectedReports: []
        )

        let source4 = """
        enum NameSpace {
            class MyViewController: UIViewController {
                func fetchData() {
                    DispatchQueue.global().async {
                        print(self!.view)
                    }
                }
            }
        }
        """
        try checkReports(
            source: source4,
            expectedReports: [
                .init(
                    position: .init(
                        file: #fileID,
                        line: 4,
                        character: 42
                    ),
                    type: .error,
                    content: defaultMessage
                )
            ]
        )
    }

    func testMethodArgumentInStruct() throws {
        let source = """
        struct MyItem {
            func output() {
                DispatchQueue.global().async {
                    print(self!.view)
                }
            }
        }
        """
        try checkReports(
            source: source,
            expectedReports: []
        )

        let source2 = """
        class MyClass {
            struct MyItem {
                func output() {
                    DispatchQueue.global().async {
                        print(self!.view)
                    }
                }
            }
        }
        """
        try checkReports(
            source: source2,
            expectedReports: []
        )
    }
}

extension WeakSelfCheckCoreTests {
    func testMethodArgumentWhiteList() throws {
        let source = """
        class MyViewController: UIViewController {
            func fetchData() {
                DispatchQueue.global().async {
                    print(self.view)
                }
            }
        }
        """
        try checkReports(
            source: source,
            expectedReports: [],
            whiteList: [
                .init(
                    parentPattern: "DispatchQueue.*",
                    functionName: "^(async|sync).*"
                )
            ]
        )

        try checkReports(
            source: source,
            expectedReports: [
                .init(
                    position: .init(
                        file: #fileID,
                        line: 3,
                        character: 38
                    ),
                    type: .error,
                    content: defaultMessage
                )
            ],
            whiteList: [
                .init(
                    parentPattern: "DispatchQueue.main*",
                    functionName: "^(async|sync).*"
                )
            ]
        )
    }
}

extension WeakSelfCheckCoreTests {
    fileprivate func checkReports(
        source: String,
        expectedReports: [Report] = [],
        whiteList: [WhiteListElement] = []
    ) throws {
        var reports: [Report] = expectedReports
        let reporter: CallbackReporter = .init { report in
            XCTAssert(
                reports.contains(report),
                "Unexpected report: \(report)"
            )
            if let index = reports.firstIndex(of: report) {
                reports.remove(at: index)
            }
        }
        let checker = WeakSelfChecker(
            fileName: #fileID,
            reporter: reporter,
            whiteList: whiteList
        )

        try checker.diagnose(source: source)
    }
}
