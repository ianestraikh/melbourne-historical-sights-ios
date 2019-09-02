//
//  SightsTableViewController.swift
//  melbourne-historical-sights
//
//  Created by fit5140 on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import MapKit

class SightsTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    let SECTION_SORT = 0;
    let SECTION_SIGHT = 1;
    
    let CELL_SIGHT = "sightCell"
    let CELL_SORT = "sortCell"
    
    var sights: [Sight] = []
    var filteredSights: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    
    var mapViewController: MapViewController?
    
    var sortSegmentedControl: UISegmentedControl?

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
        if let searchText = searchController.searchBar.text,searchText.count > 0 {
            filteredSights = sights.filter({(sight: Sight) -> Bool in
                return sight.name!.contains(searchText)
            })
        } else {
            filteredSights = sights;
            if let sortType = sortSegmentedControl?.selectedSegmentIndex {
                sortFitleredSights(type: sortType)
            }
        }
        
        tableView.reloadData();
    }
    
    @IBAction func sortSegmentedControlChanged(sender: UISegmentedControl?) {
        let sortType = sortSegmentedControl!.selectedSegmentIndex
        sortFitleredSights(type: sortType)
        
        tableView.reloadData();
    }
    
    func sortFitleredSights(type: Int) {
        if type == 0 {
            filteredSights = filteredSights.sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() })
        } else if type == 1 {
            filteredSights = filteredSights.sorted(by: { $0.name!.lowercased() > $1.name!.lowercased() })
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_SIGHT {
            return filteredSights.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_SIGHT {
            let sightCell = tableView.dequeueReusableCell(withIdentifier: CELL_SIGHT, for: indexPath) as! SightTableViewCell
            let sight = filteredSights[indexPath.row]
            
            sightCell.nameLabel.text = sight.name
            sightCell.descLabel.text = sight.desc
            if let img = loadImageData(filename: sight.imageFilename!) {
                // Get thumbnail from image
                // https://stackoverflow.com/questions/40675640/creating-a-thumbnail-from-uiimage-using-cgimagesourcecreatethumbnailatindex
    //            let imageData = img.pngData()
    //            let options = [
    //                kCGImageSourceCreateThumbnailWithTransform: true,
    //                kCGImageSourceCreateThumbnailFromImageAlways: true,
    //                kCGImageSourceThumbnailMaxPixelSize: 100] as CFDictionary
    //            let source = CGImageSourceCreateWithData(imageData! as CFData, nil)!
    //            let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
    //            let thumbnail = UIImage(cgImage: imageReference)
                
                sightCell.imgView.image = img
            }
            return sightCell
        }
        
        let sortCell = tableView.dequeueReusableCell(withIdentifier: CELL_SORT, for: indexPath) as! SortTableViewCell
        sortCell.selectionStyle = .none
        sortSegmentedControl = sortCell.sortSegmentedConrol
        return sortCell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_SIGHT {
            return true
        }
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete && indexPath.section == SECTION_SIGHT {
            // Delete the row from the data source
            let sight = filteredSights[indexPath.row]
            
            filteredSights.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let _ = databaseController?.deleteSight(sight: sight)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_SIGHT {
            let sight = filteredSights[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            mapViewController?.sightToFocus = sight
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sightSegue" {
            let destination = segue.destination as! SightDetailViewController
            destination.sight = sender as? Sight
        }
    }

}
