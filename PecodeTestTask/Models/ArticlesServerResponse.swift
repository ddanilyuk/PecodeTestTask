//
//  ArticlesServerResponse.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 06.09.2020.
//

import Foundation


struct ArticlesServerResponse: Codable {
    var status: String
    
    /// Server show invalid total results.
    var totalResults: Int
    var articles: [Article]
}
