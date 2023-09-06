//
//  ImageRequest.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-08-31.
//

import Foundation

struct ImageRequest: RequestProtocol {
        
    let endpoint: String
    let httpMethod: HTTPMethod = .GET
    let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    
    func request() throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = httpMethod.rawValue
        return request
    }
}
