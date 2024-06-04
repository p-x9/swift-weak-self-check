//
//  Syntax+.swift
//
//
//  Created by p-x9 on 2024/06/05
//  
//

import Foundation
import SwiftSyntax

extension SyntaxProtocol {
    /// A Boolean value that indicates whether it is a syntax that exists inside the reference type.
    ///
    /// If it is `nil`, it means that it is inside the extension or protocol and cannot be determined.
    var isInReferencetype: Bool? {
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
