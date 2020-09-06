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
    
    override func prepareForReuse() {
        articleImageView.image = nil
        articleNameLabel.text = ""
        articleDescriptionLabel.text = ""
        articleAuthorAndSourceLabel.text = ""
        articleImageActivityIndicator.startAndShow()
    }
    
    var articleImageURL: URL? {
        didSet {
            articleImageView.image = nil
            updateImage()
        }
    }
    
    func updateImage() {
        self.articleImageActivityIndicator.startAnimating()
        
        if let drinkImageURL = articleImageURL {
            /// If image already cached, use it!
            if let cachedImage = imageCache.object(forKey: drinkImageURL.absoluteString as NSString)  {
                articleImageView.image = cachedImage
                self.articleImageActivityIndicator.stopAndHide()
            } else {
                /// If not, download in and cache
                downloadAndCacheImage()
            }
        }
    }
    
    
    func downloadAndCacheImage() {
        if let url = articleImageURL {
            articleImageActivityIndicator.startAndShow()
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let contensOfUrl = try Data(contentsOf: url)
                    DispatchQueue.main.async { [weak self] in
                        /// Checking if this cell need this image.
                        if url == self?.articleImageURL {
                            if let image = UIImage(data: contensOfUrl) {
                                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                                self?.articleImageView.image = image
                            } else {
                                self?.articleImageView.image = UIImage(named: "placeholder")
                            }
                            self?.articleImageActivityIndicator.stopAndHide()
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async { [weak self] in
                        self?.articleImageView.image = UIImage(named: "placeholder")
                        self?.articleImageActivityIndicator.stopAndHide()
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
