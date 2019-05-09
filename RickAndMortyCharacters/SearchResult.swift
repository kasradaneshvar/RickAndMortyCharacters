//
//  SearchResult.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/8/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import Foundation

struct SearchResult: Codable {
    
    var info: Info
    var results: [CharacterInfo]
    
    struct Info: Codable {
        var count: Int
        var next: String
    }
}
