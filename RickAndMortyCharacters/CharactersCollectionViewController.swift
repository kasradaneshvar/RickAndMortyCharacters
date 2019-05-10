//
//  CharactersCollectionViewController.swift
//  Scratch
//
//  Created by Kasra Daneshvar on 5/4/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit


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
                    if let pagination = try? JSONDecoder().decode(PageContent.self, from: jsonData) {
                        self?.characterCount = pagination.info.count
                        //                        DispatchQueue.main.async {
                        //                            self?.spinner.stopAnimating()
                        //                        }
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
        spinner.stopAnimating()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath)
        if let characterCell = cell as? CharacterCollectionViewCell {
            characterCell.spinner.startAnimating()
            if characterInfoDictionary[indexPath.item + 1] == nil {
                characterCell.imageView.setBlankAvatar()
                if let url = characterURL?.appendingPathComponent(String(indexPath.item + 1)) {
                    loadCharacterInfo(fromURL: url) {
                        collectionView.reloadItems(at: [indexPath])
                    }
                }
            } else {
                if let characterInfo = characterInfoDictionary[indexPath.item + 1] {
                    characterCell.label.text = characterInfo.name
                    if let image = cachedImages.object(forKey: characterInfo.image as NSString) as? UIImage {
                        characterCell.imageView.image = image
                        characterCell.spinner.stopAnimating()
                    }
                    else {
                        characterInfo.fetchImage { result in
                            switch result {
                            case .success(_):
                                //                                    cachedImages.setObject(image, forKey: characterInfo.image as NSString)
                                collectionView.reloadItems(at: [indexPath])
//                                if let characterCell = (self.collectionView.cellForItem(at: IndexPath(item: characterInfo.id - 1, section: 0))) as? CharacterCollectionViewCell {
//                                    characterCell.imageView.image = image
//                                }
//
                            default:
                                print("error fetching image for item \(indexPath.item)")
                                characterCell.imageView.setBlankAvatar()
                            }
                        }
                        
                    }
                    
                }
            }
        }
        
        return cell
    }
    
    
    
    // MARK: - Fetching character info and setting cells.
    // 🔺🔺 Too many threads.
    func loadCharacterInfo(fromURL url: URL, completion: @escaping () -> Void ) {
        url.requestContent(forCodableType: CharacterInfo.self) { result in
            switch result {
            // 🔺 Safe to use `self`?
            case .success(let pageContent): characterInfoDictionary[pageContent.id] = pageContent
                completion()
            default: print("character info unavailable")
            }
        }
    }
    
    
    // MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Show Info Detail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Info Detail" {
            if let indexPath = sender as? IndexPath {
                if let ctvc = segue.destination as? CharacterDetailViewController {
                    ctvc.characterInfo = characterInfoDictionary[indexPath.item + 1]
                }
            }
        }
    }
    
}
