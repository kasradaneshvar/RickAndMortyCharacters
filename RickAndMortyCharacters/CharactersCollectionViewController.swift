//
//  CharactersCollectionViewController.swift
//  Scratch
//
//  Created by Kasra Daneshvar on 5/4/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

let characterURL = URL(string: "https://rickandmortyapi.com/api/character/")

class CharactersCollectionViewController: UICollectionViewController {
    
    var characterCount: Int? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if characterCount == nil {
            // fetchCharacterCount()
        }
    }
    
    private func fetchCharacterCount() {
        spinner.startAnimating()
        if let url = characterURL {
            DispatchQueue.global(qos: .default).async { [weak self] in
                if let jsonData = try? Data(contentsOf: url) {
                    if let pagination = try? JSONDecoder().decode(Pagination.self, from: jsonData) {
                        self?.characterCount = pagination.info.count
                        //                        DispatchQueue.main.async {
                        //                            self?.spinner.stopAnimating()
                        //                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Navigation
    // ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️ id might be nil
    // id is not indexPath.item
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "Show Info Detail", sender: indexPath)
        print(indexPath.item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Info Detail" {
            if let indexPath = sender as? IndexPath {
                if let ctvc = segue.destination as? CharacterDetailViewController {
                    ctvc.characterInfo = characterInfoDictionary[indexPath.item]
                    if let characterCell = (collectionView.cellForItem(at: indexPath)) as? CharacterCollectionViewCell {
                        if let image = characterCell.imageView.image, let name = characterCell.label.text {
                            ctvc.characterImage = image
                            ctvc.characterName = name
                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 493 //characterCount ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath.item)
        spinner.stopAnimating()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath)
        if let characterCell = cell as? CharacterCollectionViewCell {
            characterCell.label.text = "\(indexPath.item)"
            
//            characterCell.spinner.startAnimating()
//            if characterInfoDictionary[indexPath.item] == nil {
//                fetchCharacterInfo(forItem: indexPath.item)
//            }
//            else {
//                lastFetchedItem = indexPath.item
//            }
        }
        return cell
    }
    

    
    // MARK: - Fetching character info and setting cells.
    var characterInfoDictionary: [Int:CharacterInfo] = [:]
    
    var lastFetchedItem: Int? {
        didSet {
            if let item = lastFetchedItem {
                setCharacterName(forItem: item)
                setCharacterImage(forItem: item)
            }
        }
    }

    func fetchCharacterInfo(forItem item: Int) {
        if characterInfoDictionary[item] == nil {
            let id = item + 1
            if let url = characterURL?.appendingPathComponent(String(id)) {
                DispatchQueue.global(qos: .default).async { [weak self] in
                    if let jsonData = try? Data(contentsOf: url) {
                        if let characterInfo = try? JSONDecoder().decode(CharacterInfo.self, from: jsonData) {
                            DispatchQueue.main.async {
                                self?.characterInfoDictionary[item] = characterInfo
                                self?.lastFetchedItem = item
                            }
                            
                        }
                    } else {
                        print("character json decode error")
                    }
                }
            }
        }
    }
    
    var fetchedImageForItem: [Int:UIImage] = [:]
    
    func setCharacterImage(forItem item: Int) {
        if let characterCell = (self.collectionView.cellForItem(at: IndexPath(item: item, section: 0))) as? CharacterCollectionViewCell {
            if fetchedImageForItem[item] == nil {
                if let characterInfo = characterInfoDictionary[item] {
                    if let imageURL = URL(string: characterInfo.image) {
                        characterCell.spinner.startAnimating()
                        DispatchQueue.global(qos: .default).async {
                            if let imageData = try? Data(contentsOf: imageURL) {
                                let image = UIImage(data: imageData)
                                DispatchQueue.main.async {

                                        characterCell.imageView.image = image
                                    characterCell.spinner.stopAnimating()
                                }
                            }
                        }
                    }
                }
            } else {
                characterCell.imageView.image = fetchedImageForItem[item]
            }
        }
    }
    
    func setCharacterName(forItem item: Int) {
        if let characterInfo = characterInfoDictionary[item] {
            let name = characterInfo.name
            if let characterCell = (self.collectionView.cellForItem(at: IndexPath(item: item, section: 0))) as? CharacterCollectionViewCell {
                characterCell.label.text = name
            }
        }
    }
    
}

// MARK: - Cache
let fetchedImageCache = NSCache<AnyObject, AnyObject>()

// MARK: - UILabel extension
//extension UILabel {
//    func fetchLabelText(fromURL url: URL, @escaping
//}
