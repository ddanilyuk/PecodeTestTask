//
//  Category.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 06.09.2020.
//

import Foundation


// Can`t mix with source
enum Category: String, CaseIterable, Codable {
    case allCategories = "All categories"
    case business = "business"
    case entertainment = "entertainment"
    case general = "general"
    case health = "health"
    case science = "science"
    case sports = "sports"
    case technology = "technology"
}
