//
//  ReporterProtocol.swift
//  swift-weak-self-check
//
//  Created by p-x9 on 2025/04/20
//  
//

import Foundation

public protocol ReporterProtocol {
    func report(
        file: String,
        line: Int,
        character: Int?,
        type: ReportType,
        content: String
    )
}
