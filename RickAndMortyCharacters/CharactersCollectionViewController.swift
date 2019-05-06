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
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "Show Info Detail" {
                if let indexPath = sender as? IndexPath {
                    if let ctvc = segue.destination as? CharacterDetailViewController {
                        //                    ctvc.characterIdentifier = indexPath.item + 1
                        //                    if let (name, image) = characterCellInfo[indexPath.item + 1] {
                        //                        ctvc.characterImage = image
                        //                        ctvc.characterName = name
                        ctvc.characterInfo = characterInfoDictionary[indexPath]
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
    
    //    var characterCellInfo: [Int:(String?, UIImage?)] = [:]
    
    //    private func fetchCellInfo(forCharacterIdentifier characterIdentifier: Int) {
    //        if characterCellInfo[characterIdentifier] == nil {
    //            // 🔺 There is a catch here: if `fetchCe..ier` is called
    //            //  again before the thread returns, there would be an
    //            //  overwrite and probably a crash. Couldn't find a good
    //            //  way to avoid that except by adding a 'nil-ish' value
    //            //  for the key. Perhaps something like `addKey` and optional
    //            //  values would have been better but that would cause other
    //            //  problems/errors.
    //            characterCellInfo[characterIdentifier] = (nil, nil)
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
    //                                        self?.collectionView.reloadItems(at: [IndexPath(item: characterIdentifier - 1, section: 0)])
    //                                    }
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    var characterInfoDictionary: [IndexPath:CharacterInfo] = [:]
    
    var indexOfTheLastFetchedCharacterInfo: IndexPath? {
        didSet {
            if let indexPath = indexOfTheLastFetchedCharacterInfo {
                setCharacterName(forIndexPath: indexPath)
                setCharacterImage(forIndexPath: indexPath)
            }
        }
    }
    //
    func fetchCharacterInfo(forIndexPath indexPath: IndexPath) {
        if characterInfoDictionary[indexPath] == nil {
            let id = indexPath.item + 1
            if let url = characterURL?.appendingPathComponent(String(id)) {
                DispatchQueue.global(qos: .default).async { [weak self] in
                    if let jsonData = try? Data(contentsOf: url) {
                        if let characterInfo = try? JSONDecoder().decode(CharacterInfo.self, from: jsonData) {
                            DispatchQueue.main.async {
                                self?.characterInfoDictionary[indexPath] = characterInfo
                                self?.indexOfTheLastFetchedCharacterInfo = indexPath
                            }
                            
                        }
                    } else {
                        print("character json decode error")
                    }
                }
            }
        }
    }
    
    func setCharacterImage(forIndexPath indexPath: IndexPath) {
        if let characterInfo = characterInfoDictionary[indexPath] {
            if let imageURL = URL(string: characterInfo.image) {
                DispatchQueue.global(qos: .default).async { [weak self] in
                    if let imageData = try? Data(contentsOf: imageURL) {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            if let characterCell = (self?.collectionView.cellForItem(at: indexPath)) as? CharacterCollectionViewCell {
                                characterCell.imageView.image = image
                                characterCell.spinner.stopAnimating()
                                //self?.collectionView.reloadItems(at: [indexPath])
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setCharacterName(forIndexPath indexPath: IndexPath) {
        if let characterInfo = characterInfoDictionary[indexPath] {
            let name = characterInfo.name
            if let characterCell = (self.collectionView.cellForItem(at: indexPath)) as? CharacterCollectionViewCell {
                characterCell.label.text = name
                //collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    // ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️ 'name' sometimes doesn't show up
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        spinner.stopAnimating()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath)
        if let characterCell = cell as? CharacterCollectionViewCell {
            characterCell.spinner.startAnimating()
            if characterInfoDictionary[indexPath] == nil {
                fetchCharacterInfo(forIndexPath: indexPath)
            }
        }
        return cell
        
        //        if let characterCell = cell as? CharacterCollectionViewCell {
        //            characterCell.spinner.startAnimating()
        //            if characterCellInfo[indexPath] == nil {
        //                fetchCharacterInfo(forIndexPath: indexPath)
        //            }
        //            print(indexPath.item)
        //            if let (name, image) = characterCellInfo[characterIdentifier] {
        //                if let cellLabelText = name, let cellImage = image {
        //                    characterCell.image.image = cellImage
        //                    characterCell.label.text = cellLabelText
        //                    characterCell.spinner.stopAnimating()
        //                }
        //            }
        //        }
    }
    
    
        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.performSegue(withIdentifier: "Show Info Detail", sender: indexPath)
        }
    
    
    /*
     // TODO
     // A `func` that returns JSON from a URL.
     // Problem is `return` from within a queue.
     func fetchJSONData(fromURL url: URL) -> Data? {
     DispatchQueue.global(qos: .default).async {
     if let jsonData = try? Data(contentsOf: url) {
     return jsonData
     }
     }
     */
    
}
