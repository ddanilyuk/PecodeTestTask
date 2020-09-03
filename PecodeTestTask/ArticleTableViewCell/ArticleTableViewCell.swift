//
//  AtricleTableViewCell.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleNameLabel: UILabel!
    @IBOutlet weak var articleDescriptionLabel: UILabel!
    @IBOutlet weak var articleAuthorAndSourceLabel: UILabel!
    @IBOutlet weak var articleImageActivityIndicator: UIActivityIndicatorView!
    
    var articleImageURL: URL? {
        didSet {
            articleImageView.image = nil
            updateImage()
        }
    }
    
    func updateImage() {
        if let url = articleImageURL {
            articleImageActivityIndicator.isHidden = false
            articleImageActivityIndicator.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                let contensOfUrl = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if url == self?.articleImageURL {
                        if let imageData = contensOfUrl {
                            self?.articleImageView.image = UIImage(data: imageData)
                        } else {
                            self?.articleImageView.image = UIImage(named: "placeholder")
                        }
                        self?.articleImageActivityIndicator.stopAnimating()
                        self?.articleImageActivityIndicator.isHidden = true
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        articleImageView.layer.cornerRadius = 8
        articleImageView.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
