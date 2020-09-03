//
//  Article.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import Foundation


struct ServerResponse: Codable {
    var status: String
    var totalResults: Int
    var articles: [Article]
}


struct ArticleSource: Codable {
    var id: String?
    var name: String?
}


struct Article: Codable {
    var source: ArticleSource
    var author: String?
    var title: String
    var description: String?
    var url: String
    var urlToImage: String?
    var publishedAt: String
    var content: String?
}
