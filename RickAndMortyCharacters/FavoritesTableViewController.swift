//
//  FavoritesTableViewController.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/10/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {

    let documentsURL = try?  FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    
    var favoriteCharacters: [Character] = []
    
    func fetchFavorites() {
        if let url = documentsURL {
            if let directoryContents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
                let jsonFiles = directoryContents.filter { $0.pathExtension == "json" }
                jsonFiles.forEach {
                    // Should have used `requestContent`. But apparently the threaded nature of
                    //  it will make it unhelpful.
                    if let favoriteCharacterData = try? Data(contentsOf: $0) {
                        if let favoriteCharacter = try? JSONDecoder().decode(Character.self, from: favoriteCharacterData) {
                            self.favoriteCharacters.append(favoriteCharacter)
                            characterInfoDictionary[favoriteCharacter.characterInfo.id] = favoriteCharacter.characterInfo
                        }
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFavorites()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCharacters.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Favorite Result Cell", for: indexPath)
        if let resultCell = cell as? ResultsTableViewCell {
            let character = favoriteCharacters[indexPath.item]
            resultCell.nameLabel.text = character.characterInfo.name
            if let characterImage = cachedImages.object(forKey: character.characterInfo.image as NSString) as? UIImage {
                resultCell.resultImageView.image = characterImage
            } else {
                resultCell.resultImageView.setBlankAvatar()
                character.characterInfo.fetchImage { result in
                    switch result {
                    case .success(_):
                        tableView.reloadRows(at: [indexPath], with: .none)
                    default: print("error: favorite character image not found.")
                    }
                }
            }

        }
        return cell
    }





    
    // MARK: - Navigation
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Show Info Detail", sender: indexPath)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Info Detail" {
            if let indexPath = sender as? IndexPath {
                if let ctvc = segue.destination as? CharacterDetailViewController {
                    ctvc.characterInfo = favoriteCharacters[indexPath.item].characterInfo
                }
            }
        }
    }

}



