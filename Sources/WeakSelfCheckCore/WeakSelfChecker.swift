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
import SwiftIndexStore
import SourceReporter

public final class WeakSelfChecker: SyntaxVisitor {
    public let fileName: String
    public let reportType: ReportType
    public let reporter: any ReporterProtocol
    public let whiteList: [WhiteListElement]
    public let indexStore: IndexStore?

    public init(
        fileName: String,
        reportType: ReportType = .error,
        reporter: any ReporterProtocol = XcodeReporter(),
        whiteList: [WhiteListElement] = [],
        indexStore: IndexStore? = nil
    ) {
        self.fileName = fileName
        self.reportType = reportType
        self.reporter = reporter
        self.whiteList = whiteList
        self.indexStore = indexStore

        super.init(viewMode: .all)
    }

    public override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard !checkIfContainsInWhiteList(node) else {
            return .visitChildren
        }

        func hasEscaping(
            for label: String?,
            isTrailing: Bool = false
        ) -> Bool {
            guard let funcDecl = try? functionDecl(for: node) else {
                return true
            }
            let parameters = funcDecl.signature.parameterClause.parameters

            var parameter: FunctionParameterSyntax?

            if let label {
                parameter = parameters.first(where: {
                    $0.secondName?.trimmedDescription == label ||
                    $0.firstName.trimmedDescription == label
                })
            } else if parameters.count(where: \.isFunctionType) == 1 {
                parameter = parameters.first(where: {
                    $0.isFunctionType
                })
            }
            // TODO: Handle function which has multiple closures without label

            guard let parameter else { return true }

            if parameter.isFunctionType,
               !parameter.type.isOptionalType,
               !parameter.isEscaping {
                return false
            }

            return true
        }

        for argument in node.arguments {
            guard let closure = argument.expression.as(ClosureExprSyntax.self) else {
                continue
            }
            if !ClosureWeakSelfChecker.check(closure, in: fileName, indexStore: indexStore),
               hasEscaping(for: argument.label?.trimmedDescription) {
                report(for: closure)
            }
        }

        // Check trailing closure
        if let trailingClosure = node.trailingClosure,
           !ClosureWeakSelfChecker.check(trailingClosure, in: fileName, indexStore: indexStore),
           hasEscaping(for: nil, isTrailing: true) {
            report(for: trailingClosure)
        }

        // Check additional trailing closures
        for closure in node.additionalTrailingClosures {
            if !ClosureWeakSelfChecker.check(closure.closure, in: fileName, indexStore: indexStore),
               hasEscaping(for: closure.label.trimmedDescription, isTrailing: true) {
                report(for: closure.closure)
            }
        }

        return .visitChildren
    }

    public func diagnose() throws {
        let source = try String(contentsOfFile: fileName)
        try diagnose(source: source)
    }

    internal func diagnose(source: String) throws {
        let syntax: SourceFileSyntax = Parser.parse(source: source)
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
        reporter.report(
            file: fileName,
            line: location.line,
            column: location.column,
            type: reportType,
            content: "Use `[weak self]` to avoid memory leaks"
        )
    }
}

extension WeakSelfChecker {
    private func checkIfContainsInWhiteList(_ node: FunctionCallExprSyntax) -> Bool {
        guard !whiteList.isEmpty else {
            return false
        }

        let calledExpression = node.calledExpression

        if let function = calledExpression.as(DeclReferenceExprSyntax.self) {
            return !whiteList
                .lazy
                .filter({ $0.parentPattern == nil })
                .filter({ function.trimmed.description.matches(pattern: $0.functionName) })
                .isEmpty
        }

        if let memberAccess = calledExpression.as(MemberAccessExprSyntax.self) {
            var names = memberAccess.chainedMemberNames

            guard let function = names.popLast() else { return false }
            let parent = names.joined(separator: ".")

            return !whiteList
                .lazy
                .filter({
                    parent.matches(pattern: $0.parentPattern ?? "") && function.matches(pattern: $0.functionName)
                })
                .isEmpty
        }

        return false
    }
}

extension WeakSelfChecker {
    private func functionDecl(for callExpr: FunctionCallExprSyntax) throws -> FunctionDeclSyntax? {
        guard let occurrence = try functionCallOccurrence(for: callExpr) else {
            return nil
        }

        var calledExpression = callExpr.calledExpression
        if let member = calledExpression.as(MemberAccessExprSyntax.self) {
            calledExpression = ExprSyntax(member.declName)
        }
        return occurrence.symbol.functionDecl(
            calledExpression.trimmedDescription
        )
    }

    private func functionCallOccurrence(for callExpr: FunctionCallExprSyntax) throws -> IndexStoreOccurrence? {
        guard let indexStore else { return nil }

        var calledExpression = callExpr.calledExpression

        if let member = calledExpression.as(MemberAccessExprSyntax.self) {
            calledExpression = ExprSyntax(member.declName)
        }

        let location = calledExpression.startLocation(
            converter: .init(
                fileName: fileName,
                tree: calledExpression.root
            )
        )

        var occurrence: IndexStoreOccurrence?

        try indexStore.forEachUnits(includeSystem: false) { unit in
            let mainFilePath = try indexStore.mainFilePath(for: unit)
            guard mainFilePath == fileName else { return true }

            try indexStore.forEachRecordDependencies(for: unit) { dependency in
                guard case let .record(record) = dependency,
                      record.filePath == fileName else {
                    return true
                }

                try indexStore.forEachOccurrences(for: record) {
                    let l = $0.location
                    if !l.isSystem,
                       l.line == location.line && l.column == location.column,
                       $0.roles.contains([.reference, .call]),
                       [.instanceMethod, .classMethod, .staticMethod, .constructor, .function, .conversionFunction].contains($0.symbol.kind) {
                        occurrence = $0
                        return false
                    }
                    return true
                } // forEachOccurrences

                return false
            } // forEachRecordDependencies

            return occurrence == nil
        } // forEachUnits

        return occurrence
    }
}
