//
//  String+.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation

extension String {
    package func matches(pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(startIndex ..< endIndex, in: self)
            let match = regex.firstMatch(in: self, range: range)
            return match != nil
        } catch {
            return false
        }
    }
}

extension String {
    /// Finds the index of the matching closing bracket for a given opening bracket.
    /// - Parameters:
    ///   - open: The opening bracket character.
    ///   - close: The closing bracket character.
    /// - Returns: The index of the matching closing bracket if found, otherwise `nil`.
    /// - Complexity: O(n), where n is the length of the string.
    func indexForMatchingBracket(
        open: Character,
        close: Character
    ) -> Int? {
        var depth = 0
        for (index, char) in enumerated() {
            depth += (char == open) ? 1 : (char == close) ? -1 : 0
            if depth == 0 {
                return index
            }
        }
        return nil
    }
}
