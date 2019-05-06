//
//  CharacterInfo.swift
//  Scratch
//
//  Created by Kasra Daneshvar on 5/4/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import Foundation

struct CharacterInfo: Codable {
    
    var name: String
    var status: String
    var species: String
    var type: String
    var gender: String
    var origin: Origin
    var location: Location
    var image: String
    
    struct Origin: Codable {
        var name: String
        var url: String
    }
    
    struct Location: Codable {
        var name: String
        var url: String
    }
    
}
