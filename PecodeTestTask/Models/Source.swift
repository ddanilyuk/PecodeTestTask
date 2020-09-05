//
//  Source.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 06.09.2020.
//

import Foundation


struct Source: Codable, Equatable {
    var id: String?
    var name: String?
    var description: String?
    var url: String?
    var category: Category?
    var language: String?
    var country: String?
}
