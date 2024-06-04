//
//  WeakSelfChecker.swift
//
//
//  Created by p-x9 on 2024/06/04
//
//

import Foundation
import SwiftParser
import SwiftSyntax

public final class WeakSelfChecker: SyntaxVisitor {
    public let fileName: String

    public init(fileName: String) {
        self.fileName = fileName
        super.init(viewMode: .all)
    }

    public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
#if canImport(SwiftSyntax510)
        let arguments = node.arguments
#else
        let arguments = node.argumentList
#endif

        for argument in arguments {
            guard let closure = argument.expression.as(ClosureExprSyntax.self) else {
                continue
            }
            if !ClosureWeakSelfChecker.check(closure) {
                report(for: closure)
            }
        }

        // Check trailing closure
        if let trailingClosure = node.trailingClosure,
           !ClosureWeakSelfChecker.check(trailingClosure) {
            report(for: trailingClosure)
        }

        // Check additional trailing closures
        for closure in node.additionalTrailingClosures {
            if !ClosureWeakSelfChecker.check(closure.closure) {
                report(for: closure.closure)
            }
        }

        return .visitChildren
    }

    public func diagnose() throws {
        let input = try String(contentsOfFile: fileName)
        let syntax: SourceFileSyntax = Parser.parse(source: input)
        self.walk(syntax)
    }
}

extension WeakSelfChecker {
    private func report(for closure: ClosureExprSyntax) {
        let location = closure.startLocation(
            converter: .init(
                fileName: fileName,
                tree: closure.root
            )
        )
        Reporter.report(
            file: fileName,
            line: location.line,
            character: location.column,
            type: .error,
            content: "Use `[weak self]` to avoid memory leaks"
        )
    }
}
