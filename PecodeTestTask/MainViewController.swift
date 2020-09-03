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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
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
    
    
    @IBAction func didPressFilterButton(_ sender: UIButton) {
        guard let filterViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: FilterViewController.identifier) as? FilterViewController else {
            return
        }
        self.present(filterViewController, animated: true, completion: nil)
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else { return UITableViewCell() }
        
        let article = news[indexPath.row]
        
        cell.articleNameLabel.text = article.title
        cell.articleDescriptionLabel.text = article.description
        
        if let urlToImage = article.urlToImage {
            cell.articleImageURL = URL(string: urlToImage)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
