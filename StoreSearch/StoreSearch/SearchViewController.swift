//
//  ViewController.swift
//  StoreSearch
//
//  Created by  Максим Мартынов on 15.04.2021.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
   private let search = Search()
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    var landscapeVC: LandscapeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        searchBar.becomeFirstResponder()
        searchBar.searchTextField.textColor = .white
        
        
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: segmentColor]
        segmentedControl.selectedSegmentTintColor = segmentColor
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
            detailViewController.searchResult = searchResult
            }
        }
    }
    
    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator) {
      super.willTransition(to: newCollection, with: coordinator)
      switch newCollection.verticalSizeClass {
      case .compact:
        showLandscape(with: coordinator)
      case .regular, .unspecified:
        hideLandscape(with: coordinator)
      @unknown default:
        fatalError()
      }
    }
    // MARK:- Helper methods
   
    
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment: "Error alert: title"), message: NSLocalizedString("There was an error accessing the iTunes Store. Please, try again.", comment: "Error alert: message"), preferredStyle: .alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert action: OK"), style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
      guard landscapeVC == nil else { return }
        searchBar.resignFirstResponder()
        
      landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController")
                                                          as? LandscapeViewController
      if let controller = landscapeVC {
        controller.search = search
        controller.view.frame = view.bounds
        controller.view.alpha = 0
        
        view.addSubview(controller.view)
        addChild(controller)
        coordinator.animate(alongsideTransition: {_ in
            controller.view.alpha = 1
            if self.presentedViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
        }, completion: {_ in
            controller.didMove(toParent: self)
        })
      }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(alongsideTransition: {_ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
        search.performSearch(for: searchBar.text!, category: category, completion: { success in
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
            self.landscapeVC?.searchResultsReceived()
        })
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results( let list):
        return list.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
            
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
           return cell
            
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
            }
        }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .loading, .notSearchedYet, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
}
