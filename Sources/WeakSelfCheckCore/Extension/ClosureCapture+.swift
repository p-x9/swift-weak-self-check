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
        guard let specifier else { return false }
#if canImport(SwiftSyntax601)
        let name = self.name
#else
        guard let expression = expression.as(DeclReferenceExprSyntax.self) else {
            return false
        }
        let name = expression.baseName
#endif
        if specifier.specifier.tokenKind == .keyword(.weak),
           name.tokenKind == .keyword(.`self`) {
            return true
        }
        return false
    }

    var isUnownedSelf: Bool {
        guard let specifier else { return false }
#if canImport(SwiftSyntax601)
        let name = self.name
#else
        guard let expression = expression.as(DeclReferenceExprSyntax.self) else {
            return false
        }
        let name = expression.baseName
#endif
        if specifier.specifier.tokenKind == .keyword(.unowned),
           name.tokenKind == .keyword(.`self`) {
            return true
        }
        return false
    }
}
