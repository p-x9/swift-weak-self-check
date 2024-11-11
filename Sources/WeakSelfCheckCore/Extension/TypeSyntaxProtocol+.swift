//
//  TypeSyntaxProtocol+.swift
//  swift-weak-self-check
//
//  Created by p-x9 on 2024/11/11
//  
//

import Foundation
import SwiftSyntax

extension TypeSyntaxProtocol {
    /// A boolean value that indicates whatever the type is a closure type.
    var isFunctionType: Bool {
        if kind == .functionType {
            return true
        }

        if let type = self.as(MemberTypeSyntax.self) {
            if type.name.tokenKind == .identifier("Optional"),
               let genericArgumentClause = type.genericArgumentClause,
               let argument = genericArgumentClause.arguments.first {
                return argument.argument.isFunctionType
            }
            return type.baseType.isFunctionType
        }
        if let type  = self.as(AttributedTypeSyntax.self) {
            return type.baseType.isFunctionType
        }
        if let type = self.as(OptionalTypeSyntax.self) {
            return type.wrappedType.isFunctionType
        }
        if let type = self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return type.wrappedType.isFunctionType
        }

        if let type = self.as(IdentifierTypeSyntax.self),
           type.name.tokenKind == .identifier("Optional"),
           let genericArgumentClause = type.genericArgumentClause,
           let argument = genericArgumentClause.arguments.first {
            return argument.argument.isFunctionType
        }

        return false
    }
}

extension TypeSyntaxProtocol {
    var isOptionalType: Bool {
        if let type = self.as(OptionalTypeSyntax.self) {
            return true
        }
        if let type = self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return true
        }
        if let type = self.as(MemberTypeSyntax.self),
           type.name.tokenKind == .identifier("Optional") {
            return true
        }
        if let type = self.as(IdentifierTypeSyntax.self),
           type.name.tokenKind == .identifier("Optional") {
            return true
        }
        return false
    }
}
