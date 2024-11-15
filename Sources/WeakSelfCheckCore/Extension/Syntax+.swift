//
//  Syntax+.swift
//
//
//  Created by p-x9 on 2024/06/05
//  
//

import Foundation
import SwiftSyntax
import SwiftIndexStore

extension SyntaxProtocol {
    /// A Boolean value that indicates whether it is a syntax that exists inside the reference type.
    ///
    /// If it is `nil`, it means that it is inside the extension or protocol and cannot be determined.
    fileprivate  var isInReferencetype: Bool? {
        var current: (any SyntaxProtocol)? = self
        while current?.hasParent ?? false {
            guard let _current = current,
                  let parent = _current.parent else {
                break
            }

            defer {
                current = parent
            }

            switch parent.kind {
            case .classDecl: fallthrough
            case .actorDecl:
                return true
            case .structDecl: fallthrough
            case .enumDecl:
                return false
            case .extensionDecl: fallthrough
            case .protocolDecl:
                return nil
            default:
                continue
            }
        }
        
        return  nil
    }
}

extension SyntaxProtocol {
    /// A Boolean value that indicates whether it is a syntax that exists inside the reference type.
    ///
    /// Based on syntax and indexStore information to determine.
    /// If it is `nil`, it means that it is inside the extension or protocol and cannot be determined.
    ///
    /// - Parameters:
    ///   - fileName: Path of the file containing this syntax
    ///   - indexStore: Index Store Path
    /// - Returns: Whether this syntax is internal to the reference type.
    func isInReferenceType(in fileName: String, indexStore: IndexStore?) throws -> Bool? {
        guard let indexStore else {
            return isInReferencetype
        }

        // If known from syntax infos
        if let isInReferencetype {
            return isInReferencetype
        }

        guard let _containedTypeDecl = containedTypeDecl,
              let containedTypeName = _containedTypeDecl.declTypeName else {
            return nil
        }

        let location = containedTypeName.startLocation(
            converter: .init(
                fileName: fileName,
                tree: containedTypeName.root
            )
        )

        var occurrence: IndexStoreOccurrence?

        try indexStore.forEachUnits(includeSystem: false) { unit in
            try indexStore.forEachRecordDependencies(for: unit) { dependency in
                guard case let .record(record) = dependency,
                      record.filePath == fileName else {
                    return true
                }

                try indexStore.forEachOccurrences(for: record) {
                    let l = $0.location
                    if !l.isSystem,
                       l.line == location.line && l.column == location.column,
                       $0.roles.contains([.reference, .extendedBy]) {
                        occurrence = $0
                        return false
                    }
                    return true
                } // forEachOccurrences

                return false
            } // forEachRecordDependencies

            return occurrence == nil
        } // forEachUnits

        guard let occurrence else { return nil }

        let kind = occurrence.symbol.kind
        let name = occurrence.symbol.name
        switch kind {
        case .class: return true
        case .struct: return false
        case .enum where name != "Optional": return false
        case .protocol: return nil
        default: return nil
        }
    }
}

extension SyntaxProtocol {
    var containedTypeDecl: DeclSyntax? {
        var current: (any SyntaxProtocol)? = self
        while current?.hasParent ?? false {
            guard let _current = current,
                  let parent = _current.parent else {
                break
            }

            defer {
                current = parent
            }

            switch parent.kind {
            case .classDecl: fallthrough
            case .actorDecl: fallthrough
            case .structDecl: fallthrough
            case .enumDecl: fallthrough
            case .extensionDecl: fallthrough
            case .protocolDecl:
                return DeclSyntax(parent)
            default:
                continue
            }
        }

        return  nil
    }
}

extension DeclSyntax {
    var declTypeName: SyntaxProtocol? {
        if let decl = self.as(ClassDeclSyntax.self) {
            return decl.name
        }

        if let decl = self.as(ActorDeclSyntax.self) {
            return decl.name
        }

        if let decl = self.as(StructDeclSyntax.self) {
            return decl.name
        }

        if let decl = self.as(EnumDeclSyntax.self) {
            return decl.name
        }

        if let decl = self.as(ProtocolDeclSyntax.self) {
            return decl.name
        }

        if let decl = self.as(ExtensionDeclSyntax.self) {
            let extendedType = decl.extendedType
            if let member = extendedType.as(MemberTypeSyntax.self) {
                return member.name
            }
            return decl.extendedType
        }

        return nil
    }
}
