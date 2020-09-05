//
//  NetworkingAPI.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import Foundation


struct Filter: Codable {
    var category: Category?
    var country: Country?
    var sources: [Source]?
}


class NetworkingAPI {

    static let apiKEY = "fc72af4dbdfe47c8b80ceca8463fd809"
//    static let apiKEY = "411b721aa2e94b808962e7ab284f1ee4"
    
    typealias DataComplition = (Data) -> ()
    
    func getNews(querie: String?, filter: Filter, page: Int, complition: @escaping DataComplition) {
        
            var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: NetworkingAPI.apiKEY),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        if let category = filter.category {
            if category != .allCategories {
                queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
            }
        }
        
        if let country = filter.country {
            queryItems.append(URLQueryItem(name: "country", value: country.rawValue))
        }
        
        if let querie = querie {
            queryItems.append(URLQueryItem(name: "q", value: querie))
        }
        
        if let sources = filter.sources {

            if !sources.isEmpty {
                queryItems.append(
                    URLQueryItem(name: "sources", value: sources.map({$0.id}).reduce("", {part1, part2 in "\(part1 ?? ""),\(part2 ?? "")"}))
                )
            }

        }
        
        guard var urlComponents = URLComponents(string: "https://newsapi.org/v2/top-headlines") else { return }
        
        urlComponents.queryItems = queryItems
        
        
        guard let url = urlComponents.url else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
                let str = String(decoding: data, as: UTF8.self)
//                print(str)
                complition(data)
            }
            
        })
        dataTask.resume()
        
    }
    
    func getAllSources(complition: @escaping (([Source]) -> ())) {
        
        let stringURL = "https://newsapi.org/v2/sources?apiKey=\(NetworkingAPI.apiKEY)"
        
        guard let url = URL(string: stringURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print(url)
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            if let data = data {
                let str = String(decoding: data, as: UTF8.self)
                print(str)

                let decoder = JSONDecoder()
                let sourcesResonse = try? decoder.decode(AllSorcesServerResponse.self, from: data)
                complition(sourcesResonse?.sources ?? [])
            }
        })
        dataTask.resume()
    }
    
}
