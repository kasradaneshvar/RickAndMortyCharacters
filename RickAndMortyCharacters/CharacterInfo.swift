//
//  CharacterInfo.swift
//  Scratch
//
//  Created by Kasra Daneshvar on 5/4/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import Foundation

struct CharacterInfo: Codable {
    
    var id: Int
    var name: String
    var image: String

    var status: String
    var species: String
    var gender: String

    var location: Location
    
    struct Location: Codable {
        var name: String
        var url: String
        
        func about() -> [(String, String)] {
            return [
                ("name", name),
                ("url", url)
            ]
        }
    }
    
    func about() -> [(String, String)] {
        return [
            ("status", status),
            ("species", species),
            ("gender", gender)
        ]
    }
}
