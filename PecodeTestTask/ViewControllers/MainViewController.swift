//
//  MainViewController.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit
import SafariServices


class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    var tableViewRefreshControll: UIRefreshControl!

    let api = NetworkingAPI()

    var news: [Article] = []
    
    // Searching
    var isSearching = false
    var newsInSearch: [Article] = []
    let search = UISearchController(searchResultsController: nil)
    //
    
    var settings = Settings()
    
    // Pagination
    var currentPage: Int = 1
    var articlesInPage: Int = 20
    //
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControll()
        setupSearch()
        setupTableView()
        
        startLoading(with: "Loading fresh news...")

        setupFirstLaunch()
        
        loadFirstPage()
    }

    @objc func refresh(sender: UIRefreshControl) {
        loadFirstPage()
    }
    
    private func setupRefreshControll() {
        tableViewRefreshControll = UIRefreshControl()
        tableViewRefreshControll.attributedTitle = NSAttributedString(string: "Updating news")
        tableViewRefreshControll.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }
    
    private func startLoading(with text: String = "Loading...") {
        loadingView.isHidden = false
        tableView.isHidden = true
        loadingActivityIndicator.startAndShow()
        loadingLabel.isHidden = false
        loadingLabel.text = text
    }
    
    private func stopLoading() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
            self.loadingActivityIndicator.stopAndHide()
            self.loadingLabel.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
    private func setupFirstLaunch() {
        if !settings.isFirstLaunch || settings.allSources.isEmpty {
            startLoading(with: "Loading all possible sources...")
            api.getAllSources { [weak self] sources in
                self?.settings.allSources = sources
                self?.settings.isFirstLaunch = true
                self?.stopLoading()
            }
        }
    }
    
    private func setupTableView() {
        tableView.refreshControl = tableViewRefreshControll
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
        filterViewController.delegate = self

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
    
    private func downloadAndCacheImagesForNewNews(atricles: [Article]) {
        for article in atricles {
            if let url = URL(string: article.urlToImage ?? "") {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let contensOfUrl = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            if let image = UIImage(data: contensOfUrl) {
                                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadFirstPage() {
        api.getNews(querie: nil, filter: settings.selectedFilter, page: 1) { [weak self] data  in
            let serverResponse = try? JSONDecoder().decode(ArticlesServerResponse.self, from: data)
            if let serverResponse = serverResponse {
                DispatchQueue.main.async {
                    print("LOG: First page of news loaded...")
                    self?.tableViewRefreshControll.endRefreshing()
                    self?.stopLoading()
                    self?.news = []
                    self?.downloadAndCacheImagesForNewNews(atricles: serverResponse.articles)
                    self?.news = serverResponse.articles
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? newsInSearch.count : news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else { return UITableViewCell() }
        
        let article = isSearching ? newsInSearch[indexPath.row] : news[indexPath.row]
        
        cell.articleNameLabel.text = article.title
        cell.articleDescriptionLabel.text = article.description
        cell.articleAuthorAndSourceLabel.text = "\(article.source.name ?? "No source") | \(article.author ?? "No author")"
        
        if let urlToImage = article.urlToImage {
            cell.articleImageURL = URL(string: urlToImage)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let article = isSearching ? newsInSearch[indexPath.row] : news[indexPath.row]
        
        if let url = URL(string: article.url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard !isSearching else { return }
        /// Functions to load more news when user reached end
        if news.count == indexPath.row + 1 {
            print("LOG: Downloading new news!")
            api.getNews(querie: nil, filter: settings.selectedFilter, page: currentPage + 1) { [weak self] data  in
                let serverResponse = try? JSONDecoder().decode(ArticlesServerResponse.self, from: data)
                if let serverResponse = serverResponse {
                    DispatchQueue.main.async {
                        guard let this = self else { return }
                        this.tableViewRefreshControll.endRefreshing()
                        this.stopLoading()
                        print("LOG: New news downloaded!")
                        
                        if (this.news.count / this.articlesInPage) != this.currentPage + 1 {
                            print("LOG: New news APPLY!!!")
                            this.downloadAndCacheImagesForNewNews(atricles: serverResponse.articles)
                            this.news.append(contentsOf: serverResponse.articles)
                            this.currentPage += 1
                            this.tableView.reloadData()
                        }
                    }
                }
            }
        } else {
            print("LOG: This \(indexPath) is not last cell")
        }
    }
    
}


extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        let lowerCaseSearchText = searchText.lowercased()
        
        if lowerCaseSearchText == "" {
            newsInSearch = []
            isSearching = false
            self.stopLoading()
        } else {
            isSearching = true
        }
        
        if isSearching {
            if lowerCaseSearchText.count < 2 {
                self.startLoading(with: "Searching news...")
            }
            let serchingFilter = Filter(category: nil, country: settings.selectedFilter.country, sources: settings.selectedFilter.sources)
            
            api.getNews(querie: lowerCaseSearchText, filter: serchingFilter, page: 1) { [weak self] data in
                
                if let serverResponse = try? JSONDecoder().decode(ArticlesServerResponse.self, from: data) {
                    DispatchQueue.main.async {
                        guard let this = self else { return }
                        this.stopLoading()
                        print(serverResponse.articles.count)
                        this.newsInSearch = serverResponse.articles
                        this.tableView.reloadData()
                    }
                    
                }
            }
            
        }
        tableView.reloadData()
    }
    
}


extension MainViewController: FilterViewControllerDelegate {
    
    func filterParametersChanged(filter: Filter) {
        settings.selectedFilter = filter
        self.startLoading(with: "Loading news...")
        loadFirstPage()
    }
    
}
