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
    
    func fetchFavorites(completion: @escaping () -> Void) {
        if let url = documentsURL {
            print(url)
            if let directoryContents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
                let jsonFiles = directoryContents.filter { $0.pathExtension == "json" }
                jsonFiles.forEach {
                    $0.requestContent(forCodableType: Character.self) { result in
                        switch result {
                        case .success(let item): self.favoriteCharacters.append(item)
                        default: return
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFavorites() {
            self.tableView.reloadData()
            print(self.favoriteCharacters.count)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(favoriteCharacters.count)
        return favoriteCharacters.count
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



