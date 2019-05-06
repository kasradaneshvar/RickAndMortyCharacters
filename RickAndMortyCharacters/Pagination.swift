//
//  Pagination.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/5/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import Foundation

extension Pagination.Info {
    
}

struct Pagination: Codable {
    
    var info: Info
    
    struct Info: Codable {
        var count: Int
    }
}
