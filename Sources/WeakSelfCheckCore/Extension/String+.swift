//
//  String+.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation

extension String {
    func matches(pattern: String) -> Bool {
        let predicate = NSPredicate(format: "SELF LIKE %@", pattern)
        return predicate.evaluate(with: self)
    }
}
