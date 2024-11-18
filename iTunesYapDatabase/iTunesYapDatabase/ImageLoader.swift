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

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {

        guard let url = URL(string: urlString) else {
            completion(nil)
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
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}

