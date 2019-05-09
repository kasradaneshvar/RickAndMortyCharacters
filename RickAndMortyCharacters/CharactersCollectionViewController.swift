//
//  CharactersCollectionViewController.swift
//  Scratch
//
//  Created by Kasra Daneshvar on 5/4/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

let characterURL = URL(string: "https://rickandmortyapi.com/api/character/")
let blankAvatarURL = Bundle.main.url(forResource: "blankAvatar", withExtension: "jpeg")

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
    
    
    
    // MARK: - Navigation
    // ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️ id might be nil
    // id is not indexPath.item
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Show Info Detail", sender: indexPath)
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
//        print(indexPath.item)
        spinner.stopAnimating()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath)
        if let characterCell = cell as? CharacterCollectionViewCell {
            characterCell.label.text = "\(indexPath.item)"
            if let url = blankAvatarURL {
                if let blankAvatarData = try? Data(contentsOf: url) {
                    
                    if let blankAvatar = UIImage(data: blankAvatarData) {
                        characterCell.imageView.image = blankAvatar
                    }
                }
            }
            characterCell.spinner.startAnimating()
            if characterInfoDictionary[indexPath.item + 1] == nil {
                    
                
                if let url = characterURL?.appendingPathComponent(String(indexPath.item + 1)) {
                    loadCharacterInfo(fromURL: url) {
                        collectionView.reloadItems(at: [indexPath])
                        print("\(indexPath.item) -> k\(url)")
                    }
                }
                
                    
//                    fetchCharacterInfo(forItem: indexPath.item) { // [weak self] in
//                        //                    if let characterInfo = self?.characterInfoDictionary[indexPath.item] {
//                        //                        if let imageURL = URL(string: characterInfo.image) {
//                        //                            characterCell.imageView.loadImage(usingURL: imageURL) { result in
//                        //                                switch result {
//                        //                                case .success(let image): characterCell.imageView.image = image
//                        //                                default: print("error fetching image for item \(indexPath.item)")
//                        //                                }
//                        //                            }
//                        //                        }
//                        //
//                        //                        characterCell.label.text = characterInfo.name
//                        //                    }
                
                    
            } else {
                    
                    if let characterInfo = characterInfoDictionary[indexPath.item + 1] {
                        characterCell.label.text = characterInfo.name
                        if let image = cachedImages.object(forKey: characterInfo.image as NSString) as? UIImage {
                            characterCell.imageView.image = image
                            characterCell.spinner.stopAnimating()
                        } else {
                            characterInfo.fetchImage { result in
                                print("fetching image for \(characterInfo.name)")
                                switch result {
                                case .success(let image):
                                    print("fetched image for \(characterInfo.name)")
                                    cachedImages.setObject(image, forKey: characterInfo.image as NSString)
                                    //                                collectionView.reloadItems(at: [indexPath])
                                    if let characterCell = (self.collectionView.cellForItem(at: IndexPath(item: characterInfo.id - 1, section: 0))) as? CharacterCollectionViewCell {
                                        characterCell.imageView.image = image
                                    }
                                    
                                default: print("error fetching image for item \(indexPath.item)")
                                }
                            }
                        }
                    }
                }
            }
        
        return cell
    }
    

    
    // MARK: - Fetching character info and setting cells.
    
//    var lastFetchedItem: Int? {
//        didSet {
//            if let item = lastFetchedItem {
//                setCharacterName(forItem: item)
//                setCharacterImage(forItem: item)
//            }
//        }
//    }

    // 🔺🔺 Too many threads.
    func loadCharacterInfo(fromURL url: URL, completion: @escaping () -> Void ) {
        url.requestPageContent(forCodableType: CharacterInfo.self) { result in
            switch result {
            // 🔺 Safe to use `self`?
            case .success(let pageContent): characterInfoDictionary[pageContent.id] = pageContent
                print("added key \(pageContent.id)")
                completion()
            default: print("character info unavailable")
            }
        }
    }

    
//    func fetchCharacterInfo(forItem item: Int, completion: @escaping () -> Void) {
//        if characterInfoDictionary[item] == nil {
//            let id = item + 1
//            if let url = characterURL?.appendingPathComponent(String(id)) {
//                DispatchQueue.global(qos: .default).async {
//                    if let jsonData = try? Data(contentsOf: url) {
//                        if let characterInfo = try? JSONDecoder().decode(CharacterInfo.self, from: jsonData) {
//                            DispatchQueue.main.async {
//                                characterInfoDictionary[item] = characterInfo
//                                completion()
//                            }
//
//                        }
//                    } else {
//                        print("character json decode error")
//                    }
//                }
//            }
//        }
//    }
    
}

var characterInfoDictionary: [Int:CharacterInfo] = [:]

// MARK: - Cache
let cachedImages = NSCache<AnyObject, AnyObject>()

//var fetchedImageArray = [UIImage]()

// MARK: - UILabel extension
//extension UILabel {
//    func fetchLabelText(fromURL url: URL, @escaping completion: (Result<)
//}

// MARK: - UIImageView extension to fetch and update cell image.
extension UIImageView {
    func loadImage(usingCharacterInfo characterInfo: CharacterInfo, completion : @escaping (Result<(UIImage, Int), Error>) -> Void) {
//        if let image = fetchedImageArray[safe: characterInfo.id] {
//            completion(.success((image,characterInfo.id)))
//        } else {
        DispatchQueue.global(qos: .default).async {

            if let imageURL = URL(string: characterInfo.image) {
                    if let imageData = try? Data(contentsOf: imageURL) {
                        if let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
//                                fetchedImageArray.insert(image, at: characterInfo.id)
                                completion(.success((image, characterInfo.id)))
                            }
                        }
                    }
                }
            }
//        }

//        if let image = fetchedImageArray.object(forKey: url as NSURL) as? UIImage {
//            completion(.success((image, url)))
//        } else {
//            DispatchQueue.global(qos: .default).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    if let image = UIImage(data: imageData) {
//                        DispatchQueue.main.async {
//                            fetchedImageArray.setObject(image, forKey: url as NSURL)
//                            completion(.success((image, url)))
//                        }
//                    }
//                }
//            }
//        }
    }
}
