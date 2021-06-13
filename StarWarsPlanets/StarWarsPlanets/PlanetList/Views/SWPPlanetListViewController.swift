//
//  SWPPlanetListViewController.swift
//  StarWarsPlanets
//
//  Created by Vibin Xavier on 11/06/21.
//

import UIKit

class SWPPlanetListViewController: UIViewController {
    
// MARK: - Properties
    private var planetListPresenter = SWPPlanetListPresenter()
    var planetDataSource: [Planet] = [Planet]()
    var searchSource: [Planet] = [Planet]()
    
// MARK: - IBOutlets
    @IBOutlet weak var planetListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
// MARK: - ViewController lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up the ViePresenter delegate for the presenter class
        planetListPresenter.setViewDelegate(delegate: self)
        // Data fetch request for the list
        planetListPresenter.fetchPlanetData{ data in
            self.reloadfetchedPlanetData(data: data)
        }
    }

// MARK: - IBActions
    // Refresh button action
    @IBAction func refreshButtonAction(_ sender: Any) {
        // Dismissing the keyboard from the screen
        searchBar.resignFirstResponder()
        // Invoking the presenter method to trigger the online API call.
        planetListPresenter.reloadPlanetData { data in
            self.reloadfetchedPlanetData(data: data)
        }
    }
    // Tapgesture action to dismiss the keyboard from the screen
    @IBAction func tapGestureAction(_ sender: Any) {
        // Dismissing the keyboard from the screen
        searchBar.resignFirstResponder()
    }
// MARK: - PrivateMethods
        // Reload Data method
    private func reloadfetchedPlanetData(data: [Planet]?) {
        if let data = data {
            // Updating the dtasource for tableview list view and search
            self.planetDataSource = data
            self.searchSource = self.planetDataSource
            self.searchBar.text = ""
            // Tableview refresh
            self.planetListTableView.reloadData()
        }
    }
    
}

// MARK: - SWPPlanetListPresenterDelegate

extension SWPPlanetListViewController : SWPPlanetListPresenterDelegate {
    // Delgate call back method for  data fetch
    func didFinishPlanetDataFetch(data: [Planet]?) {
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource

extension SWPPlanetListViewController : UITableViewDelegate, UITableViewDataSource{
    //Method to define number of rows for the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Tableview cell count
        return planetDataSource.count
    }
    //Method to create and configure the tableview cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: kSWPPlanetCellIdentifier, for: indexPath)
        // Fetch the planet data for the cell from datasource
        let planet = self.planetDataSource[indexPath.row]
        //Cell configuration
        aCell.textLabel?.text = planet.name
        return aCell
    }
}
// MARK: - UISearchBarDelegate

extension SWPPlanetListViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Searching the the particular search text in search datasource and updating the tablevie datasource.
        self.planetDataSource = planetListPresenter.searchPlanetFromDataSource(source: self.searchSource, with: searchText)
        // Tableview refresh
        self.planetListTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}



