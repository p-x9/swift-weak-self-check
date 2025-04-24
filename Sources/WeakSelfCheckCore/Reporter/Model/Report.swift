//
//  Report.swift
//  swift-weak-self-check
//
//  Created by p-x9 on 2025/04/24
//  
//

import Foundation

public struct Report: Sendable, Codable, Equatable {
    public struct Position: Sendable, Codable, Equatable {
        public let file: String
        public let line: Int
        public let character: Int?
    }

    public let position: Position
    public let type: ReportType
    public let content: String
}
