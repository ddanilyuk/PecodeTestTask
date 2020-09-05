//
//  Settings.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 05.09.2020.
//

import Foundation


public class Settings {
    
    private var userDefaults = UserDefaults.standard
    
    static let shared = Settings()
    
    var isFirstLaunch: Bool {
        get {
            return userDefaults.bool(forKey: "isFirstLaunch2")
        }
        set {
            userDefaults.set(newValue, forKey: "isFirstLaunch2")
        }
    }
    
    var selectedFilter: Filter {
        get {
            let selectedFilterData = userDefaults.data(forKey: "selectedFilter") ?? Data()
            let filter = try? JSONDecoder().decode(Filter.self, from: selectedFilterData)
            return filter != nil ? filter! : Filter(category: .allCategories, country: .ua, source: nil)
        }
        set {
            let selectedFilterData = try? JSONEncoder().encode(newValue)
            userDefaults.set(selectedFilterData, forKey: "selectedFilter")
        }
    }
    
    var allSources: [Source] {
        get {
            let selectedSourcesData = userDefaults.data(forKey: "allSources") ?? Data()
            let sources = try? JSONDecoder().decode([Source].self, from: selectedSourcesData)
            return sources != nil ? sources! : []
        }
        set {
            let selectedSourcesData = try? JSONEncoder().encode(newValue)
            userDefaults.set(selectedSourcesData, forKey: "allSources")
        }
    }
}
