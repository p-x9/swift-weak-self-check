//
//  FileManager+.swift
//
//
//  Created by p-x9 on 2024/06/04
//
//

import Foundation

extension FileManager {
    func isDirectory(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        if fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }

    func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        if fileExists(atPath: url.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }
}
