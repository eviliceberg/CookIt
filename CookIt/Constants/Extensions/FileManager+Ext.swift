//
//  FileManager+Ext.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-18.
//

import Foundation

extension FileManager {
    static var cachesDirectory: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
}
