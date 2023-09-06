//
//  SearchResultViewModelTests.swift
//  StorytelAppTests
//
//  Created by Tim Gunnarsson on 2023-09-01.
//

import XCTest
@testable import StorytelApp

final class SearchResultViewModelTests: XCTestCase {
    
    func testSuccessfulResponse() throws {
        let networkService = NetworkServiceMock<SearchResult>()
        networkService.set(response: ReponseMockData.searchResult)
        InjectedValues[\.networkService] = networkService
        let viewModel = SearchResultsViewModel()
        
        XCTAssertEqual(viewModel.searchQuery, "Harry")

        let expectation = XCTestExpectation()
        Task {
            do {
                let _ = try await viewModel.performSearch()
                XCTAssertEqual(viewModel.items, ReponseMockData.searchResult.items)
                XCTAssertEqual(viewModel.nextItems, ReponseMockData.searchResult.items)
                expectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
       wait(for: [expectation], timeout: 1)
    }
    
    func testEndPageReached() throws {
        let networkService = NetworkServiceMock<SearchResult>()
        networkService.set(response: ReponseMockData.searchResult)
        InjectedValues[\.networkService] = networkService
        let viewModel = SearchResultsViewModel()
        XCTAssertEqual(viewModel.searchQuery, "Harry")

        let expectation = XCTestExpectation()
        Task {
            do {
                let _ = try await viewModel.performSearch()
                let _ = try await viewModel.performSearch()

            } catch {
                XCTAssert(error is CancellationError)
                expectation.fulfill()
            }
        }
        
       wait(for: [expectation], timeout: 1)
    }
}
