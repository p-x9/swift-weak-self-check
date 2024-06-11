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
