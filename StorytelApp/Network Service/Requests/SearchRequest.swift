//
//  SearchRequest.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-08-31.
//

import Foundation

struct SearchRequest: RequestProtocol {
    
    let endpoint: String = "https://api.storytel.net/search/client"
    let httpMethod: HTTPMethod = .GET
    let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    let query: String
    let nextPageToken: String?
    
    func request() throws -> URLRequest {
        guard var components = URLComponents(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var items: [URLQueryItem] = [
            .init(name: "query", value: query),
            .init(name: "searchFor", value: "books"),
            .init(name: "store", value: "STHP-SE"),
        ]

        if let nextPageToken {
            items.append(.init(name: "page", value: nextPageToken))
        }

        components.queryItems = items
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = httpMethod.rawValue

        return request
    }
}
