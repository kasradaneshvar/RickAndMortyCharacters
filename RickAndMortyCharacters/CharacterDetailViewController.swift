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
    
    @IBOutlet weak var addToFavorite: UIButton!
    
    @IBOutlet weak var characterInfoTableView: UITableView! {
        didSet {
            characterInfoTableView.dataSource = self
            characterInfoTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateViewFromModel()
    }
    
    func updateViewFromModel() {
        if let name = characterName, let image = characterImage {
            characterNameLabel.text = name
            characterImageView.image = image
        }
    }
    

    
    // MARK: -UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 2
        default: return 0
        }
    }
    
//    private func fetchCellInfo(forCharacterIdentifier characterIdentifier: Int) {
//        //        characterCellInfo.identifier = characterIdentifier
//        if characterCellInfo[characterIdentifier] == nil {
//            if let url = characterURL?.appendingPathComponent(String(characterIdentifier)) {
//                DispatchQueue.global(qos: .default).async { [weak self] in
//                    if let jsonData = try? Data(contentsOf: url) {
//                        if let characterInfo = try? JSONDecoder().decode(CharacterInfo.self, from: jsonData) {
//                            if let imageURL = URL(string: characterInfo.image) {
//                                if let imageData = try? Data(contentsOf: imageURL) {
//                                    let name = characterInfo.name
//                                    let image = UIImage(data: imageData)
//                                    self?.characterCellInfo[characterIdentifier] = (name, image)
//                                    DispatchQueue.main.async {
//                                        self?.collectionView.reloadItems(at: [IndexPath(item: characterIdentifier, section: 0)])
//                                    }
//                                } else {
//                                    print("error: add key:value")
//                                }
//                                
//                            }
//                        } else {
//                            print("character json decode error")
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = characterInfoTableView.dequeueReusableCell(withIdentifier: "Detail Cell", for: indexPath)
        if let characterDetailCell = cell as? CharacterDetailTableViewCell {
            characterDetailCell.titleLable.text = "name"
            characterDetailCell.contentLable.text = "Rick"
        }
        return cell
//        if let characterCell = cell as? CharacterCollectionViewCell {
//            characterCell.spinner.startAnimating()
//            if characterCellInfo[indexPath.item] == nil {
//                fetchCellInfo(forCharacterIdentifier: indexPath.item)
//            }
//            print(indexPath.item)
//            if let (name, image) = characterCellInfo[indexPath.item] {
//                if let cellLabelText = name, let cellImage = image {
//                    characterCell.image.image = cellImage
//                    characterCell.label.text = cellLabelText
//                    characterCell.spinner.stopAnimating()
//                }
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("mySectionName", comment: "mySectionName")
        case 1:
            sectionName = NSLocalizedString("myOtherSectionName", comment: "myOtherSectionName")
        // ...
        default:
            sectionName = ""
        }
        return sectionName
    }
}
