//
//  Character.swift
//  Scratch
//
//  Created by Kasra Daneshvar on 5/3/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import Foundation

struct Character: Codable {
    
    var isFavorite = false

    var characterInfo: CharacterInfo
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(characterInfo: CharacterInfo) {
        self.characterInfo = characterInfo
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(Character.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
}
