//
//  CharacterDetailViewController.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/5/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class CharacterDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // It's expected that `characteridentifier` is not `nil` after
    //  segue. But it is an optional and apparently has to be, so
    //  `character` has to be initialized after unwrapping `char..ier`.
    //  Doesn't there exist a more intuitive way?
    var character: Character? {
        didSet {
            if character?.isFavorite != oldValue?.isFavorite {
                saveCharacter()
            }
            updateAddToFavoriteButton()
        }
    }
    
    var characterInfo: CharacterInfo? {
        didSet {
            aboutCharacter = characterInfo?.about()
            characterLocationDetail = characterInfo?.location.about()
            characterIdentifier = characterInfo?.id
        }
    }
    
    var characterIdentifier: Int!
    
    var characterImage: UIImage?
    
    var characterName: String?
    
    @IBOutlet weak var characterImageView: UIImageView!
    
    @IBOutlet weak var characterNameLabel: UILabel!
    
    
    func saveCharacter() {
        if let json = character?.json {
            if let id = character?.characterInfo.id {
                if let url = try?  FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                    ).appendingPathComponent("\(id).json") {
                    do {
                        try json.write(to: url)
                        print("saved successfully!")
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            } else {
            }
        } else {
        }
    }
    
    @IBOutlet weak var addToFavoriteButton: UIButton!
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        character?.isFavorite.toggle()
    }
    
    func updateAddToFavoriteButton() {
        if let isFavorite = character?.isFavorite {
            if isFavorite {
                addToFavoriteButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                addToFavoriteButton.setTitle("✓ Favorite", for: UIControl.State.normal)
            } else {
                addToFavoriteButton.backgroundColor = #colorLiteral(red: 0.7706646697, green: 0.7706646697, blue: 0.7706646697, alpha: 1)
                addToFavoriteButton.setTitle("Add to favorite", for: UIControl.State.normal)
            }
        }
    }
    
    @IBOutlet weak var characterInfoTableView: UITableView! {
        didSet {
            characterInfoTableView.dataSource = self
            characterInfoTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let id = characterIdentifier {
            if let url = try?  FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
                ).appendingPathComponent("\(id).json") {
                if let jsonData = try? Data(contentsOf: url) {
                    character = Character(json: jsonData)
                } else {
                    if let characterInfo = characterInfo {
                        character = Character(characterInfo: characterInfo )
                    }
                }
            }
        }
    }
    
    func updateViewFromModel() {
        if let name = characterName, let image = characterImage {
            characterNameLabel.text = name
            characterImageView.image = image
        }
    }
    
    // 🔺 This is by far the "best bad" idea for getting the JSON info
    //  in a way that is (a) `Sequence` and (b) patitioned. But it
    //  is obviously impractical if the keys were to be many. Converting
    //  to Array didn't help much because the structure would have been
    //  complicated and also many entries were unwanted.
    var aboutCharacter: [(String, String)]?
    var characterLocationDetail: [(String, String)]?
    
    // MARK: -UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionName: String
        switch section {
        case 0: sectionName = "About"
        case 1: sectionName = "Location"
        default: sectionName = ""
        }
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 2
        default: return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = characterInfoTableView.dequeueReusableCell(withIdentifier: "Detail Cell", for: indexPath)
        if let characterDetailCell = cell as? CharacterInfoFieldTableViewCell {
            if indexPath.section == 0 {
                if let (title, value) = aboutCharacter?[indexPath.item] {
                    characterDetailCell.titleLable.text = title
                    characterDetailCell.contentLable.text = value
                }
                return cell
            } else if indexPath.section == 1 {
                if let (title, value) = characterLocationDetail?[indexPath.item] {
                    characterDetailCell.titleLable.text = title
                    characterDetailCell.contentLable.text = value
                }
            }
        }
        return cell
    }
}
