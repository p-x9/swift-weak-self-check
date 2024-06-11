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

        let units = indexStore.units()

        for unit in units {
            let dependencies = try indexStore.recordDependencies(for: unit)
            for dependency in dependencies where dependency.filePath == fileName {
                guard case let .record(record) = dependency else {
                    continue
                }

                let occurrence = try indexStore.occurrences(for: record)
                    .lazy
                    .filter { !$0.location.isSystem }
                    .filter {
                        let l = $0.location
                        return l.line == location.line && l.column == location.column
                    }
                    .first { $0.roles.contains(.reference) && $0.roles.contains(.extendedBy) }

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

        return nil
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
