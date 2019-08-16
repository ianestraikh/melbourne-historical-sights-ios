//
//  SightsTableViewController.swift
//  melbourne-historical-sights
//
//  Created by fit5140 on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit

class SightsTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    let CELL_SIGHT = "sightCell"
    var sights: [Sight] = []
    var filteredSights: [Sight] = []
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filteredSights = sights
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sights"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    
    // MARK: - Database Listener
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        self.sights = sights
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(),searchText.count > 0 {
            filteredSights = sights.filter({(sight: Sight) -> Bool in
                return sight.name!.lowercased().contains(searchText)
            })
        } else {
            filteredSights = sights;
        }
        
        tableView.reloadData();
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sightCell = tableView.dequeueReusableCell(withIdentifier: CELL_SIGHT, for: indexPath) as! SightTableViewCell
        let sight = filteredSights[indexPath.row]
        
        sightCell.nameLabel.text = sight.name
        sightCell.descLabel.text = sight.desc
        
        return sightCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
