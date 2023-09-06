//
//  RequestProtocol.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-08-31.
//

import Foundation

protocol RequestProtocol {
    var endpoint: String { get }
    var httpMethod: HTTPMethod { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    func request() throws -> URLRequest
}

enum HTTPMethod: String {
    case GET
    case PUT
    case PATCH
    case DELETE
}
