//
//  ClosureCapture.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation
import SwiftSyntax

extension ClosureCaptureSyntax {
    var isWeakSelf: Bool {
        guard let specifier,
              let expression = expression.as(DeclReferenceExprSyntax.self) else {
            return false
        }
        if specifier.specifier.tokenKind == .keyword(.weak),
           expression.baseName.tokenKind == .keyword(.`self`) {
            return true
        }
        return false
    }

    var isUnownedSelf: Bool {
        guard let specifier,
              let expression = expression.as(DeclReferenceExprSyntax.self) else {
            return false
        }
        if specifier.specifier.tokenKind == .keyword(.unowned),
           expression.baseName.tokenKind == .keyword(.`self`) {
            return true
        }
        return false
    }
}
