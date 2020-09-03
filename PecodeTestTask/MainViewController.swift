//
//  MainViewController.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    
    var news: [Article] = []
    
    let api = NetworkingAPI()
    
    /// Searching
    var isSearching = false
    let search = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearch()
        
        api.getNews(querie: nil, sources: nil, country: nil, category: nil) { [weak self] data  in
            let serverResponse = try? JSONDecoder().decode(ServerResponse.self, from: data)
            if let serverResponse = serverResponse {
                DispatchQueue.main.async {
                    self?.news = serverResponse.articles
                    self?.tableView.reloadData()
                }
            }
        }
    }

    
    private func setupTableView() {
        tableView.register(UINib(nibName: ArticleTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ArticleTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupSearch() {
        /// Search bar settings
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search news"
        search.searchBar.tintColor = .systemRed

        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    
    @IBAction func didPressFilterButton(_ sender: UIButton) {
        guard let filterViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: FilterViewController.identifier) as? FilterViewController else {
            return
        }
//        self.present(filterViewController, animated: true, completion: nil)
        
//        guard let newLessonViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: NewLessonViewController.identifier) as? NewLessonViewController  else { return }
//        newLessonViewController.delegate = self

        let navigationController = UINavigationController()
        
        navigationController.viewControllers = [filterViewController]
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.barTintColor = UIColor.systemGroupedBackground
        
        if #available(iOS 13, *) {
            self.present(navigationController, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(filterViewController, animated: true)
        }
    }
    
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else { return UITableViewCell() }
        
        let article = news[indexPath.row]
        
        cell.articleNameLabel.text = article.title
        cell.articleDescriptionLabel.text = article.description
        cell.articleAuthorAndSourceLabel.text = "\(article.source.name ?? "No source") | \(article.author ?? "No author")"
        
        if let urlToImage = article.urlToImage {
            cell.articleImageURL = URL(string: urlToImage)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        print(searchText)
    }
}
