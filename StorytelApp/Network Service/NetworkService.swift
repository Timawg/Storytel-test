//
//  NetworkService.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-08-31.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol {
    func perform(request: RequestProtocol) async throws -> Data
    func perform<T: Decodable>(request: RequestProtocol) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    
    private static var urlCache: URLCache {
        let cacheSizeMemory = 20 * 1024 * 1024 // 20 MB
        let cacheSizeDisk = 100 * 1024 * 1024 // 100 MB
        let cache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "URLCacheDirectory")
        return cache
    }
 
    init(session: URLSession? = nil) {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = NetworkService.urlCache
        self.session = session ?? URLSession(configuration: config)
    }
    
    func perform(request: RequestProtocol) async throws -> Data {
        return try await session.data(for: request.request()).0
    }
    
    func perform<T: Decodable>(request: RequestProtocol) async throws -> T {
        let data = try await perform(request: request)
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
}
