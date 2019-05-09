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
    
    var searchResultsCharacterInfo: [CharacterInfo] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }
    
    var lastFetchedResults: [CharacterInfo] = [] {
        didSet {
            lastFetchedResults.forEach { [weak self] in
                $0.fetchImage() { results in
                    switch results {
                    case .success(let image): self?.searchResultCharacterImage += [image]
                    default: print("fetchImage failed")
                    }
                }
            }
        }
    }
    
    var searchResultCharacterImage: [UIImage] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }

    // MARK: - `resignFirstResponder`
    @IBAction func cancelSearch(_ sender: UIButton? = nil) {
        noTextHasBeenEntered = true
        searchTextField.resignFirstResponder()
        searchTextField.text = "Enter Character Name"
        searchTextField.textColor = #colorLiteral(red: 0.7706646697, green: 0.7706646697, blue: 0.7706646697, alpha: 1)
        cancelSearchButton.setTitleColor(#colorLiteral(red: 0.7706646697, green: 0.7706646697, blue: 0.7706646697, alpha: 1), for: UIControl.State.normal)
        searchResultCharacterImage = []
        searchResultsCharacterInfo = []
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        noTextHasBeenEntered = false
        searchTextField.resignFirstResponder()
        searchResultsCharacterInfo = []
        searchResultCharacterImage = []
        enteredCharacterName = searchTextField.text
        if let url = characterFilterURL {
            searchForCharacter(inURL: url)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cancelSearchButton.setTitleColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), for: UIControl.State.normal)
        if noTextHasBeenEntered {
            searchTextField.text = ""
        }
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
    
    var searchResultPageInfo: PageContent.Info? {
        didSet {
            if searchResultPageInfo?.count != oldValue?.count {
                resultsTableView.reloadData()
            }
        }
    }
    
    func searchForCharacter(inURL url: URL) {
        // 🔺 Is ther a memory cycle?
        DispatchQueue.global(qos: .default).async { [weak self] in
            if let jsonData = try? Data(contentsOf: url) {
                if let searchResults = try? JSONDecoder().decode(PageContent.self, from: jsonData) {
                    DispatchQueue.main.async {
                        self?.searchResultPageInfo = searchResults.info
                        self?.searchResultsCharacterInfo += searchResults.results
                        self?.lastFetchedResults = searchResults.results
                        if searchResults.info.next != "" {
                            if let url = URL(string: searchResults.info.next) {
                                self?.searchForCharacter(inURL: url)
                            }
                        }
                    }

                } else {
//                    print("error: json")
                }
            } else {
//                print("error: data fetch")
            }
        }
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
        return searchResultsCharacterInfo.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "Result Cell", for: indexPath)
        if let resultCell = cell as? ResultsTableViewCell {
            resultCell.nameLabel.text = searchResultsCharacterInfo[indexPath.item].name
            if let image = searchResultCharacterImage[safe: indexPath.item] {
                resultCell.resultImageView.image = image
            }
        }
        return cell
    }

    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        <#code#>
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CharacterInfo {
    func fetchImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let imageURL = URL(string: image) {
            DispatchQueue.global(qos: .default).async {
                if let imageData = try? Data(contentsOf: imageURL) {
                    if let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            completion(.success(image))
                        }
                    }
                }
            }
        }
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension URL {
    
//    func requestPageContent(forCodable codable: Codable, completion: @escaping (Result<PageContent, Error>) -> Void) {
//        DispatchQueue.global(qos: .default).async {
//            if let jsonData = try? Data(contentsOf: self) {
//                if let requestResults = try? JSONDecoder().decode(type(of: codable), from: jsonData) {
//                    DispatchQueue.main.async {
//                        completion(.success(requestResults))
//                    }
//                } else {
//                    print("error: json decoder")
//                }
//                JSONDecoder().decode            } else {
//                print("error: fetch data")
//            }
//        }
//    }
}


