//
//  CharacterDetailViewController.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/5/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class CharacterDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var character: Character?
    
    var characterIdentifier: Int?
    
    var characterImage: UIImage?
    
    var characterName: String?
    
    @IBOutlet weak var characterImageView: UIImageView!
    
    @IBOutlet weak var characterNameLabel: UILabel!
    
    @IBAction func addToFavorite(_ sender: UIButton) {
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
    
    func updateViewFromModel() {
        if let name = characterName, let image = characterImage {
            characterNameLabel.text = name
            characterImageView.image = image
        }
    }
    
    // 🔺 This is by far the best idea for getting the JSON info
    //  in a way that is (a) `Sequence` and (b) patitioned. But it
    //  is obviously impractical if the keys were to be many. Converting
    //  to Array didn't help much because the structure would have been
    //  complicated and also many entries were unwanted.
    var aboutCharacter: [(String, String)]?
    var characterLocationDetail: [(String, String)]?
    
    var characterInfo: CharacterInfo? {
        didSet {
            aboutCharacter = characterInfo?.about()
            characterLocationDetail = characterInfo?.location.about()
        }
    }
    

    
//    private func fetchCharacterInfo(forCharacterIdentifier characterIdentifier: Int) {
//        if let url = characterURL?.appendingPathComponent(String(characterIdentifier)) {
//            DispatchQueue.global(qos: .default).async { [weak self] in
//                if let jsonData = try? Data(contentsOf: url) {
//                    if let characterInfo = try? JSONDecoder().decode(CharacterInfo.self, from: jsonData) {
//                        self?.characterInfo = characterInfo
//                    }
//                } else {
//                    print("character json decode error")
//                }
//            }
//        }
//    }

    
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
        if let characterDetailCell = cell as? CharacterDetailTableViewCell {
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
