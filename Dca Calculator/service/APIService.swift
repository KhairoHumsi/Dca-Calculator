//
//  APIService.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 24/02/2021.
//

import Foundation
import Combine

struct APIService {
    
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    let keys = ["4JQMZPS8P7UBSMDF", "9JIET5SMPV9FSC9Q", "ZC6JNZ91DMBZ4SIZ"]

    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchModel, Error> {
         
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchModel.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
}
