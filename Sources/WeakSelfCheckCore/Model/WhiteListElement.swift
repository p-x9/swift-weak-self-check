//
//  WhiteListElement.swift
//
//
//  Created by p-x9 on 2024/06/04
//  
//

import Foundation

public struct WhiteListElement: Codable {
    public let parentPattern: String?
    public let functionName: String

    public init(parentPattern: String?, functionName: String) {
        self.parentPattern = parentPattern
        self.functionName = functionName
    }
}
