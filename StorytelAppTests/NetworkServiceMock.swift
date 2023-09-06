//
//  NetworkServiceMock.swift
//  StorytelAppTests
//
//  Created by Tim Gunnarsson on 2023-09-01.
//

import Foundation
@testable import StorytelApp

final class NetworkServiceMock<T>: NetworkServiceProtocol {
    
    private var response: T!
    
    func set(response: T) {
        self.response = response
    }
    
    func perform(request: StorytelApp.RequestProtocol) async throws -> Data {
        do {
            let request = try request.request()
        } catch {
            throw error
        }
        
        return response as! Data
    }
    
    func perform<T>(request: StorytelApp.RequestProtocol) async throws -> T where T : Decodable {
        do {
            let request = try request.request()
        } catch {
            throw error
        }
        
        return response as! T
    }
}
