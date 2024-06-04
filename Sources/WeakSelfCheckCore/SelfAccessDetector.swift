//
//  SelfAccessDetector.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation
import SwiftSyntax

public enum SelfAccessDetector {
    public static func check(_ node: SyntaxProtocol) -> Bool {
        let visitor = _SelfAccessDetectSyntaxVisitor(viewMode: .all)
        visitor.walk(node)
        return visitor.isSelfUsed
    }
}

fileprivate final class _SelfAccessDetectSyntaxVisitor: SyntaxVisitor {
    public private(set) var isSelfUsed: Bool = false

    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        if let base = node.base?.as(DeclReferenceExprSyntax.self),
           base.baseName.tokenKind == .keyword(.`self`) {
            isSelfUsed = true
            return .skipChildren
        }
        return .visitChildren
    }
}
