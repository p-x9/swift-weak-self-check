//
//  Config.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation
import WeakSelfCheckCore

public struct Config: Codable {
    public var reportType: ReportType = .warning
    public var slent: Bool = false
    public var whiteList: [WhiteListElement] = []
}
