//
//  NetworkServiceMock.swift
//  StorytelAppTests
//
//  Created by Tim Gunnarsson on 2023-09-01.
//

import Foundation
@testable import StorytelApp

#warning("Using URLSessions's protocolClasses would be a better option")
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









class MockURLProtocol: URLProtocol {
    static var error: Error?
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    
    override func startLoading() {
        
        if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
