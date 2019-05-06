//
//  CharacterDetailTableViewCell.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/6/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class CharacterDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var contentLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
