//
//  ClosureWeakSelfChecker.swift
//
//
//  Created by p-x9 on 2024/06/04
//
//

import Foundation
import SwiftSyntax
import SwiftIndexStore

public enum ClosureWeakSelfChecker {
    public static func check(
        _ node: ClosureExprSyntax,
        in fileName: String,
        indexStore: IndexStore? = nil
    ) -> Bool {
        let visitor = _ClosureWeakSelfCheckerSyntaxVisitor(
            fileName: fileName,
            indexStore: indexStore
        )
        visitor.walk(node)
        return visitor.isValid
    }
}

fileprivate final class _ClosureWeakSelfCheckerSyntaxVisitor: SyntaxVisitor {

    let fileName: String
    let indexStore: IndexStore?

    public private(set) var isValid: Bool = true

    init(fileName: String, indexStore: IndexStore?) {
        self.fileName = fileName
        self.indexStore = indexStore
        super.init(viewMode: .all)
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        let statements = node.statements
        let signature = node.signature
        let parameterClause = signature?.parameterClause

        // Check if `self` is used in closure.
        guard SelfAccessDetector.check(statements) else {
            return .skipChildren
        }

        // Check if `[weak self]` or `[unowned self]` is already been set.
        if let capture = signature?.capture,
           capture.items.contains(where: { $0.isWeakSelf || $0.isUnownedSelf }) {
            return .skipChildren
        }

        // Check if `self` or ``self`` is included in parameter list
        if let parameterClause {
            if let items = parameterClause.as(ClosureParameterClauseSyntax.self)?.parameters,
               items.contains(where: {
                   if let secondName = $0.secondName {
                       return secondName.tokenKind.isSelf
                   } else {
                       return $0.firstName.tokenKind.isSelf
                   }
               }) {
                return .skipChildren
            }
            if let items = parameterClause.as(ClosureShorthandParameterListSyntax.self),
               items.contains(where: {
                   return $0.name.tokenKind.isSelf
               }) {
                return .skipChildren
            }
        }

        if let isInReferencetype = try? node.isInReferenceType(
            in: fileName,
            indexStore: indexStore
        ),
           !isInReferencetype {
            return .skipChildren
        }

        self.isValid = false

        return .skipChildren
    }
}

extension TokenSyntax {
    fileprivate var isSelf: Bool {
        tokenKind.isSelf
    }
}
extension TokenKind {
    fileprivate var isSelf: Bool {
        [.keyword(.`self`), .identifier("`self`")].contains(self)
    }
}
