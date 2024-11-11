//
//  FunctionParameterSyntax+.swift
//
//
//  Created by p-x9 on 2024/06/14
//
//

import Foundation
import SwiftSyntax

extension FunctionParameterSyntax {
    /// A boolean value that indicates whatever the parameter is a closure type.
    var isFunctionType: Bool {
        type.isFunctionType
    }

    /// A boolean value that indicates whether the parameter has `@escaping` attribute.
    var isEscaping: Bool {
        guard let type = type.as(AttributedTypeSyntax.self) else {
            return false
        }
        let isEscaping = type.attributes.contains(where: {
            if case let .attribute(attribute) = $0 {
                return attribute.isEscaping
            }
            return false
        })

        return isEscaping
    }
}

extension AttributeSyntax {
    /// A boolean value that indicates whatever the attribute is `@escaping` or not.
    var isEscaping: Bool {
        guard let identifierType = attributeName.as(IdentifierTypeSyntax.self) else {
            return false
        }
        return identifierType.name.tokenKind == .identifier("escaping")
    }
}

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
