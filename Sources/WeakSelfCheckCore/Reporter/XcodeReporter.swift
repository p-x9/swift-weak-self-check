//
//  Reporter.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation

public struct XcodeReporter: ReporterProtocol {
    public init() {}
    
    public func report(
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
