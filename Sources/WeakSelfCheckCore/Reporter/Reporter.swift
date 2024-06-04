//
//  Reporter.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation

enum Reporter {
    enum ReportType: String {
        case warning
        case error
    }

    static func report(
        file: String,
        line: Int,
        character: Int? = nil,
        type: ReportType,
        content: String
    ) {
        if let character {
            print("\(file):\(line):\(character): \(type): \(content)")
        } else {
            print("\(file):\(line): \(type): \(content)")
        }
    }
}
