//
//  NetworkingAPI.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import Foundation


class NetworkingAPI {

    static let apiKEY = "411b721aa2e94b808962e7ab284f1ee4"
    
    typealias DataComplition = (Data) -> ()
    
    func getNews(querie: String?, sources: String?, country: String?, category: String?, complition: @escaping DataComplition) {
        
        let stringURL = "https://newsapi.org/v2/top-headlines?country=ru&apiKey=411b721aa2e94b808962e7ab284f1ee4"
        guard let url = URL(string: stringURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: NetworkingAPI.apiKEY)
        

        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                complition(data)
            }
            
        })
        dataTask.resume()
        
    }
    
}
