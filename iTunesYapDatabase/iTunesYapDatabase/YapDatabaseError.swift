//
//  YapDatabaseError.swift
//  iTunesYapDatabase
//
//  Created by Ибрагим Габибли on 18.11.2024.
//

import Foundation

enum YapDatabaseError: Error {
    case databaseInitializationFailed
    case encodingFailed(Error)
    case decodingFailed(Error)
}
