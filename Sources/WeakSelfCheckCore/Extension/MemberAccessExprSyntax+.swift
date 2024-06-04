//
//  MemberAccessExprSyntax+.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation
import SwiftSyntax

extension MemberAccessExprSyntax {
    var chainedExppressions: [ExprSyntax] {
        let declName: ExprSyntax = .init(declName)
        guard let base else {
            return [declName]
        }

        if let memberAccess = base.as(MemberAccessExprSyntax.self) {
            return memberAccess.chainedExppressions + [declName]
        }

        if let function = base.as(FunctionCallExprSyntax.self) {
            if let memberAccess = function.calledExpression.as(MemberAccessExprSyntax.self) {
                return memberAccess.chainedExppressions + [declName]
            }
        }

        return [base, declName]
    }

    var chainedMemberNames: [String] {
        chainedExppressions.map(\.trimmed.description)
    }
}
