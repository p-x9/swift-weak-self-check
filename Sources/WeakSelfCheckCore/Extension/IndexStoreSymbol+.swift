//
//  IndexStoreSymbol+.swift
//
//
//  Created by p-x9 on 2024/06/14
//
//

import Foundation
import SwiftIndexStore
import SwiftSyntax
import SwiftParser
import SwiftSyntaxBuilder

extension IndexStoreSymbol {
    var demangledSymbol: String? {
        guard let usr else { return nil }

        // swift symbol
        if usr.hasPrefix("s:") {
            let index = usr.lastIndex(of: ":").map { usr.index($0, offsetBy: -1) }
            if let index {
                var symbol = String(usr[index...])
                symbol.replaceSubrange(symbol.startIndex...symbol.index(symbol.startIndex, offsetBy: 1), with: "$S")
                return stdlib_demangleName(symbol)
            }
        }
        return stdlib_demangleName(usr)
    }
}

extension IndexStoreSymbol {
    func functionDecl(_ name: String) -> FunctionDeclSyntax? {
        guard language == .swift,
              let string = _functionDeclString(name) else {
            return nil
        }

        let decl: DeclSyntax = """
        \(raw: string)
        """

        let functionDecl = decl
            .as(FunctionDeclSyntax.self)

        return functionDecl
    }

    private func _functionDeclString(_ name: String) -> String? {
        guard var string = demangledSymbol else { return nil }

        if string.starts(with: "c:") { return nil }

        if string.starts(with: "("),
           let closeIndex = string.indexForMatchingBracket(open: "(", close: ")") {
            let index = string.index(string.startIndex, offsetBy: closeIndex)
            string = String(string[index...])
        }

        string = string.parentMemberStripped

        return "func " + string + " {}"
    }
}

extension String {
    fileprivate var parentMemberStripped: String {
        guard let index = firstIndex(of: "(") else {
            return self
        }
        var functionName = String(self[..<index])
        let functionExpr = String(self[index...])

        var depth = 0
        var currentIndex = functionName.index(before: functionName.endIndex)
        while functionName.startIndex < currentIndex {
            let current = functionName[currentIndex]
            if current == ">" { depth += 1 }
            if current == "<" { depth -= 1 }

            if depth == 0 && current == "." {
                currentIndex = functionName.index(after: currentIndex)
                break
            }

            currentIndex = functionName.index(before: currentIndex)
        }

        functionName = String(
            functionName[currentIndex..<functionName.endIndex]
        )

        return "\(functionName)\(functionExpr)"
    }
}
