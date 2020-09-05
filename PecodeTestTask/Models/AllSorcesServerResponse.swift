//
//  AllSorcesServerResponse.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 06.09.2020.
//

import Foundation


struct AllSorcesServerResponse: Codable {
    var status: String
    var sources: [Source]?
}
