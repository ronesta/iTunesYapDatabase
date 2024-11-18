//
//  ImageLoader.swift
//  iTunesYapDatabase
//
//  Created by Ибрагим Габибли on 18.11.2024.
//

import Foundation
import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private init() {}
    var counter = 1

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        DatabaseManager.shared.loadImage(key: urlString) { imageData in
            if let data = imageData, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                guard let url = URL(string: urlString) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let error {
                        print("Error: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    if let data,
                       let image = UIImage(data: data) {
                        DatabaseManager.shared.saveImage(data, key: urlString)
                        completion(image)
                        print("Load image", self.counter)
                        self.counter += 1
                    } else {
                        completion(nil)
                    }
                }.resume()
            }
        }
    }
}
