//
//  SearchResultCellViewModelTests.swift
//  StorytelAppTests
//
//  Created by Tim Gunnarsson on 2023-09-01.
//

import XCTest
@testable import StorytelApp

final class SearchResultCellViewModelTests: XCTestCase {

    func testMetadata() throws {
        
        let item = try XCTUnwrap(ReponseMockData.searchResult.items.first)
        
        let viewModel = SearchResultCellViewModel(item: item)
        
        XCTAssertEqual(viewModel.authors, "Authored by: John Doe")
        XCTAssertEqual(viewModel.narrators, "")
        XCTAssertEqual(viewModel.title, "Audiobook 1")
    }
    
    func testSquaredImage() throws {
        let item = try XCTUnwrap(ReponseMockData.searchResult.items.first)
        let viewModel = SearchResultCellViewModel(item: item)
        
        XCTAssertEqual(viewModel.imageAspectRatio, 1)
    }
    
    func testNonSquaredImage() throws {
        let item = try XCTUnwrap(ReponseMockData.searchResult.items[2])
        let viewModel = SearchResultCellViewModel(item: item)
        
        XCTAssertEqual(viewModel.imageAspectRatio, 0.6774193548387096)
    }

}
