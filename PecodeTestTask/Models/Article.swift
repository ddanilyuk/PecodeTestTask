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

// Can`t mix with source
enum Category: String, CaseIterable {
    case allCategories = "All categories"
    case business = "Business"
    case entertainment = "Enteratainment"
    case general = "General"
    case health = "Health"
    case science = "Science"
    case sports = "Sports"
    case technology = "Technology"
}


enum Country: String, CaseIterable {
    case ae
    case ar
    case at
    case au
    case be
    case bg
    case br
    case ca
    case ch
    case cn
    case co
    case cu
    case cz
    case de
    case eg
    case fr
    case gb
    case gr
    case hk
    case hu
    case id
    case ie
    case il
    case it
    case jp
    case kr
    case lt
    case lv
    case ma
    case mx
    case my
    case ng
    case nl
    case no
    case nz
    case ph
    case pl
    case pt
    case ro
    case rs
    case ru
    case sa
    case se
    case sg
    case si
    case sk
    case th
    case tr
    case tw
    case ua
    case us
    case ve
    case za
    
    func getFullName() -> String {
        switch self {
        case .ae:
            return "The United Arab Emirates"
        case .ar:
            return "Argentina"
        case .at:
            return "Austria"
        case .au:
            return "Australia"
        case .be:
            return "Belgium"
        case .bg:
            return "Bulgaria"
        case .br:
            return "Brazil"
        case .ca:
            return "Canada"
        case .ch:
            return "Switzerland"
        case .cn:
            return "China"
        case .co:
            return "Colombia"
        case .cu:
            return "Cuba"
        case .cz:
            return "Czechia"
        case .de:
            return "Germany"
        case .eg:
            return "Egypt"
        case .fr:
            return "France"
        case .gb:
            return "Great Britain"
        case .gr:
            return "Greece"
        case .hk:
            return "Hong Kong"
        case .hu:
            return "Hungary"
        case .id:
            return "Indonesia"
        case .ie:
            return "Ireland"
        case .il:
            return "Israel"
        case .it:
            return "Italy"
        case .jp:
            return "Japan"
        case .kr:
            return "Korea"
        case .lt:
            return "Lithuania"
        case .lv:
            return "Latvia"
        case .ma:
            return "Morocco"
        case .mx:
            return "Mexico"
        case .my:
            return "Malaysia"
        case .ng:
            return "Nigeria"
        case .nl:
            return "Netherlands"
        case .no:
            return "Norway"
        case .nz:
            return "New Zealand"
        case .ph:
            return "Philippines"
        case .pl:
            return "Poland"
        case .pt:
            return "Portugal"
        case .ro:
            return "Romania"
        case .rs:
            return "Serbia"
        case .ru:
            return "Russian Federation"
        case .sa:
            return "Saudi Arabia"
        case .se:
            return "Sweden"
        case .sg:
            return "Singapore"
        case .si:
            return "Slovenia"
        case .sk:
            return "Slovakia"
        case .th:
            return "Thailand"
        case .tr:
            return "Turkey"
        case .tw:
            return "Taiwan (Province of China)"
        case .ua:
            return "Ukraine"
        case .us:
            return "United States of America"
        case .ve:
            return "Venezuela"
        case .za:
            return "South Africa"
        }
    }
}
