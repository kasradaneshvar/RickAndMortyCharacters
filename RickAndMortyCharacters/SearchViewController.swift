//
//  SearchViewController.swift
//  RickAndMortyCharacters
//
//  Created by Kasra Daneshvar on 5/7/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

/// The idea here wa to fetch all data sequentially. That is, every batch of data is
///  fetched after the previeous batch has been fetched. To do that, a function with
///  threads one inside the other. The drawback is, the results will always appear in
/// order from first to last, and if one thread fails, all threads after that will fail.

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet weak var cancelSearchButton: UIButton!

    // MARK: - `resignFirstResponder`
    @IBAction func cancelSearch(_ sender: UIButton? = nil) {
        noTextHasBeenEntered = true
        searchTextField.resignFirstResponder()
        searchTextField.text = "Enter Character Name"
        searchTextField.textColor = #colorLiteral(red: 0.7706646697, green: 0.7706646697, blue: 0.7706646697, alpha: 1)
        cancelSearchButton.setTitleColor(#colorLiteral(red: 0.7706646697, green: 0.7706646697, blue: 0.7706646697, alpha: 1), for: UIControl.State.normal)
        
        idsOfHits = []
        numberOfHits = nil
        resultsTableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == cancelSearchButton {
                cancelSearch()
            }
        } else if searchTextField.text == "" {
            // Return to "empty mode"
        }
        searchTextField.resignFirstResponder()
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        
    }
    
    var noTextHasBeenEntered = true
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cancelSearchButton.setTitleColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), for: UIControl.State.normal)
        if noTextHasBeenEntered {
            searchTextField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        noTextHasBeenEntered = false
        searchTextField.resignFirstResponder()
        enteredCharacterName = searchTextField.text
        numberOfHits = 0
        idsOfHits = []
        if let url = characterFilterURL {
            searchForCharacter(inURL: url)
        }
        return true
    }
    
    
    
    // MARK: Search.
    var enteredCharacterName: String? {
        didSet {
            characterFilterURLComponents.scheme = "https"
            characterFilterURLComponents.host = "rickandmortyapi.com"
            characterFilterURLComponents.path = "/api/character"
            // Empty or `nil` value for query still returns results.
            //  Some special character should be set for default query
            //  value, or some better idea. Otherwise `return` from empty
            //  textField returns all characters.
            var queryItem = URLQueryItem(name: "name", value: "⧮")
            if  enteredCharacterName != nil, enteredCharacterName != "" {
                queryItem = URLQueryItem(name: "name", value: enteredCharacterName)
            }
            characterFilterURLComponents.queryItems = [queryItem]
        }
    }
    
    var characterFilterURLComponents = URLComponents()
    
    var characterFilterURL: URL? {
        get {
            return characterFilterURLComponents.url
        }
    }
    
    // MARK: - Performing the search.
    var numberOfHits: Int?
    
    var idsOfHits: [Int] = []
    
    func searchForCharacter(inURL url: URL) {
        url.requestContent(forCodableType: PageContent.self) { result in
            switch result {
            case .success(let response):
                // 🔺 `self` in closure.
                self.numberOfHits = response.info.count
                response.results.forEach { item in
                    self.idsOfHits.append(item.id)
                    if characterInfoDictionary[item.id] == nil {
                        characterInfoDictionary[item.id] = item
                        print("\(item.id) ->\(item.name)")
                    }
                }
                // 🔺🔺 `self` in closure. Very suspeciously a memory cycle.
                if let nextURL = URL(string: response.info.next) {
                    self.searchForCharacter(inURL: nextURL)
                }
            default: print("failed")
            }
        }
        
        // Tried very much to update rows "as data arrives". No luck.
        resultsTableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    @IBOutlet weak var resultsTableView: UITableView! {
        didSet {
            resultsTableView.delegate = self
            resultsTableView.dataSource = self
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfHits ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "Result Cell", for: indexPath)
        if let resultCell = cell as? ResultsTableViewCell {
            resultCell.resultImageView.setBlankAvatar()
            let characterId = idsOfHits[indexPath.item]
            if let characterInfo = characterInfoDictionary[characterId] {
                resultCell.nameLabel.text = characterInfo.name
                if let image = cachedImages.object(forKey: characterInfo.image as NSString) as? UIImage {
                    resultCell.resultImageView.image = image
                } else {
                    characterInfo.fetchImage { result in
                        switch result {
                        case .success(let image):
                            
                            
                            
                            cachedImages.setObject(image, forKey: characterInfo.image as NSString)
                            //                                collectionView.reloadItems(at: [indexPath])
                            if let resultCell = (self.resultsTableView.cellForRow(at: IndexPath(item: characterInfo.id - 1, section: 0))) as? ResultsTableViewCell {
                                resultCell.resultImageView.image = image
                            }
                            
                            
                            
                            
                            
                        default: print("error fetching image for item \(indexPath.item)")
                        }
                    }
                }
            }
        }
        return cell
    }

    
    
    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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



