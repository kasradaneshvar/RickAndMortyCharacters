//
//  Utilities.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/10/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

// MARK: - API URL and `blankAvatar`.
let characterURL = URL(string: "https://rickandmortyapi.com/api/character/")
let blankAvatarURL = Bundle.main.url(forResource: "blankAvatar", withExtension: "jpeg")

// MARK: - `characterInfoDictionary`.
// Keys are character id's.
var characterInfoDictionary: [Int:CharacterInfo] = [:]

// MARK: - Image cache.
// Image keys are `imageURL as NSString`
let cachedImages = NSCache<AnyObject, AnyObject>()

extension CharacterInfo {
    
    func fetchImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = cachedImages.object(forKey: self.image as NSString) as? UIImage {
            completion(.success(image))
            return
        } else {
            if let imageURL = URL(string: image) {
                DispatchQueue.global(qos: .default).async {
                    if let imageData = try? Data(contentsOf: imageURL) {
                        if let image = UIImage(data: imageData) {
                            cachedImages.setObject(image, forKey: self.image as NSString)
                            DispatchQueue.main.async {
                                completion(.success(image))
                                return
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension URL {
    
    func requestContent<Content: Codable>(forCodableType codableType: Content.Type, completion: @escaping (Result<Content, Error>) -> Void) {
        DispatchQueue.global(qos: .default).async {
            if let jsonData = try? Data(contentsOf: self) {
                if let requestResults = try? JSONDecoder().decode(Content.self, from: jsonData) {
                    DispatchQueue.main.async {
                        completion(.success(requestResults))
                    }
                } else {
                    print("error: json decoder")
                }
            } else {
                print("error: fetch data")
            }
        }
    }
}


extension UIImageView {
    func setBlankAvatar() {
        if let url = blankAvatarURL {
            if let blankAvatarData = try? Data(contentsOf: url) {
                if let blankAvatar = UIImage(data: blankAvatarData) {
                    self.image = blankAvatar
                }
            }
        }
    }
}
