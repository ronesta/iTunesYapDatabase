//
//  StorageManager.swift
//  iTunesYapDatabase
//
//  Created by Ибрагим Габибли on 18.11.2024.
//

import Foundation
import UIKit
import YapDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let albumsCollection = "albums"
    private let imagesCollection = "images"
    private let historyKey = "searchHistory"
    private let historyCollection = "history"

    private let database: YapDatabase
    private let connection: YapDatabaseConnection

    private init() {
        do {
            database = try DatabaseManager.setupDatabase()
            connection = database.newConnection()
        } catch {
            fatalError("Failed to initialize YapDatabase with error: \(error)")
        }
    }

    private static func setupDatabase() throws -> YapDatabase {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let baseDir = paths.first ?? NSTemporaryDirectory()
        let databaseName = "database.sqlite"
        let databasePath = (baseDir as NSString).appendingPathComponent(databaseName)

        let databaseUrl = URL(fileURLWithPath: databasePath)

        guard let databaseWithPath = YapDatabase(url: databaseUrl) else {
            throw YapDatabaseError.databaseInitializationFailed
        }

        return databaseWithPath
    }

    func saveAlbums(_ albums: [Album], for searchTerm: String) {
        do {
            let data = try JSONEncoder().encode(albums)
            connection.readWrite { transaction in
                transaction.setObject(data, forKey: searchTerm, inCollection: albumsCollection)
            }
        } catch {
            print("Failed to encode albums: \(error)")
        }
    }

    func saveImage(_ image: Data, key: String) {
        connection.readWrite { transaction in
            transaction.setObject(image, forKey: key, inCollection: imagesCollection)
        }
    }

    func loadAlbums(for searchTerm: String, completion: @escaping ([Album]?) -> Void) {
        connection.read { transaction in
            if let data = transaction.object(forKey: searchTerm, inCollection: albumsCollection) as? Data {
                do {
                    let albums = try JSONDecoder().decode([Album].self, from: data)
                    completion(albums)
                } catch {
                    print("Failed to decode albums: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    func loadImage(key: String, completion: @escaping (Data?) -> Void) {
        connection.read { transaction in
            if let data = transaction.object(forKey: key, inCollection: imagesCollection) as? Data {
                completion(data)
            } else {
                completion(nil)
            }
        }
    }

    func saveSearchTerm(_ term: String) {
        var history = getSearchHistory()
        if !history.contains(term) {
            history.append(term)
            connection.readWrite { transaction in
                transaction.setObject(history, forKey: historyKey, inCollection: historyCollection)
            }
        }
    }

    func getSearchHistory() -> [String] {
        var history = [String]()
        connection.read { transaction in
            if let dataArray = transaction.object(forKey: historyKey, inCollection: historyCollection) as? [String] {
                history = dataArray
            }
        }
        return history
    }

    func clearAlbums() {
        connection.readWrite { transaction in
            let history = getSearchHistory()
            for term in history {
                transaction.removeObject(forKey: term, inCollection: albumsCollection)
            }
            transaction.removeObject(forKey: historyKey, inCollection: historyCollection)
        }
    }

    func clearImage(key: String) {
        connection.readWrite { transaction in
            transaction.removeObject(forKey: key, inCollection: imagesCollection)
        }
    }
}
