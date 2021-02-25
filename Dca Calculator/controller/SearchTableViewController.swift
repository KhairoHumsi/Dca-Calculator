//
//  SearchTableViewController.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 24/02/2021.
//

import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController, UIAnimatable {

    private enum Mode {
        case onboarding
        case search
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchModel: SearchModel?
    
    @Published private var searchQuery = String()
    @Published private var mode : Mode = .onboarding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setUpTableView()
        observeForm()
    }

    private func setNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
    }

    private func setUpTableView() {
        tableView.tableFooterView = UIView()
    }
    
    private func observeForm() {
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                guard !searchQuery.isEmpty else { return }
                showLoadingAnimation()
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink { (completion) in
                    hideLoadingAnimation()
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished: break
                    }
                } receiveValue: { (searchModel) in
                    self.searchModel = searchModel
                    self.tableView.reloadData()
                }.store(in: &subscribers)
            }.store(in: &subscribers)
        
        $mode.sink { [unowned self] (mode) in
            switch mode {
            case .onboarding:
//                let redView = UIView()
//                redView.backgroundColor = .red
//                self.tableView.backgroundView = redView
                self.tableView.backgroundView = SearchPlaceHolderView()
            case .search:
            self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchModel?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchTableViewCell
        
        if let searchModel = self.searchModel {
            let searchResult = searchModel.items[indexPath.row]
            cell.configure(with: searchResult)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchModel = self.searchModel {
            let symbol = searchModel.items[indexPath.item].symbol
            handelSelection(for: symbol)
        }
    }
    
    private func handelSelection(for symbol: String) {
        apiService.fetchTimeSeariesMonthlyAdjustPublisher(keywords: symbol).sink { (complitionResult) in
            switch complitionResult {
            case .failure(let error):
                print(error)
            case .finished: break
            }
        } receiveValue: { (timeSeriesMonthlyAdusted) in
            print("success: \(timeSeriesMonthlyAdusted)")
        }.store(in: &subscribers)

        
//        performSegue(withIdentifier: "showCalculator", sender: nil)
    }
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
}
