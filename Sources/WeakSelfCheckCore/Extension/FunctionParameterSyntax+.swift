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

    /// A boolean value that indicates whatever the parameter is a optional type.
    var isOptionalType: Bool {
        type.isOptionalType
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
