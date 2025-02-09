//
//  CookItErrors.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-02-06.
//

import Foundation

enum CookItErrors: Error {
    case noEmailOrPassword
    case signInFailed
    case GoogleSignInFailed
    case noData
}
