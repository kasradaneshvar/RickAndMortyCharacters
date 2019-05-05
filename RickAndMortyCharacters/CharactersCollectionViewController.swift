//
//  CharactersCollectionViewController.swift
//  Scratch
//
//  Created by Kasra Daneshvar on 5/4/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

let characterURL = URL(string: "https://rickandmortyapi.com/api/character/")

class CharactersCollectionViewController: UICollectionViewController {
    
    var characterCount: Int?

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CharacterCell")

        // Do any additional setup after loading the view.
        if characterCount == nil {
            fetchCharacterCount()
        }
    }

    private func fetchCharacterCount() {
        spinner.startAnimating()
        // Or else I'd get a 'unwrap optional' error.
        //  Didn't get the logic much.
        if let url = characterURL {
            DispatchQueue.global(qos: .default).async { [weak self] in
                if let jsonData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if let pagination = try? JSONDecoder().decode(Pagination.self, from: jsonData) {
                            self?.characterCount = pagination.info.count
                            self?.spinner.stopAnimating()
                            print(self?.characterCount)
                        } else {
                            print("Can't decode JSON")
                        }
                    }
                } else {
                    print("Can't get `url` content")
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 493
    }

//    var characterCellInfo: (identifier: Int?, name: String?, image: UIImage?)
    
    var characterCellInfo: [Int:(String?, UIImage?)] = [:]
    
    private func fetchCellInfo(forCharacterIdentifier characterIdentifier: Int) {
//        characterCellInfo.identifier = characterIdentifier
        if characterCellInfo[characterIdentifier] == nil {
            if let url = characterURL?.appendingPathComponent(String(characterIdentifier)) {
                DispatchQueue.global(qos: .default).async { [weak self] in
                    if let jsonData = try? Data(contentsOf: url) {
                        if let characterInfo = try? JSONDecoder().decode(CharacterInfo.self, from: jsonData) {
                            if let imageURL = URL(string: characterInfo.image) {
                                if let imageData = try? Data(contentsOf: imageURL) {
                                    let name = characterInfo.name
                                    let image = UIImage(data: imageData)
                                    self?.characterCellInfo[characterIdentifier] = (name, image)
                                    DispatchQueue.main.async {
                                        self?.collectionView.reloadItems(at: [IndexPath(item: characterIdentifier, section: 0)])
                                    }
                                } else {
                                    print("error: add key:value")
                                }
                                
                            }
                        } else {
                            print("character json decode error")
                        }
                    }
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath)
        if let characterCell = cell as? CharacterCollectionViewCell {
            characterCell.spinner.startAnimating()
            if characterCellInfo[indexPath.item] == nil {
                fetchCellInfo(forCharacterIdentifier: indexPath.item)
            }
            print(indexPath.item)
            if let (name, image) = characterCellInfo[indexPath.item] {
                if let cellLabelText = name, let cellImage = image {
                    characterCell.image.image = cellImage
                    characterCell.label.text = cellLabelText
                    characterCell.spinner.stopAnimating()
                }
            }
        }
        return cell
    }
    
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
