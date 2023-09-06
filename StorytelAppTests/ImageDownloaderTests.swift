//
//  StorytelAppTests.swift
//  StorytelAppTests
//
//  Created by Tim Gunnarsson on 2023-09-01.
//

import XCTest
@testable import StorytelApp

final class ImageDownloaderTests: XCTestCase {
    
    @Injected(\.imageDownloader) private var imageDownloader: ImageDownloadingProtocol
    
    override func tearDown() {
        super.tearDown()
        imageDownloader.clearImageCache()
    }
    
    func testSuccessfulImageResponse() throws {
        let networkService = NetworkServiceMock<Data>()
        let expectedImage = UIImage(systemName: "questionmark.circle.fill")
        let imageData = try XCTUnwrap(expectedImage?.pngData())
        networkService.set(response: imageData)
        InjectedValues[\.networkService] = networkService
        
        let expectation = XCTestExpectation()
        Task {
            do {
                let _ = try await imageDownloader.downloadImage(for:"http://www.example.com")
                
                expectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testBadURLErrorResponse() throws {
        let networkService = NetworkServiceMock<URLError>()
        InjectedValues[\.networkService] = networkService
        
        let expectation = XCTestExpectation()
        
        Task {
            do {
                let _ = try await imageDownloader.downloadImage(for:"")
            } catch {
                XCTAssertEqual(try XCTUnwrap(error as? URLError), URLError(.badURL))
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testuncachedImage() throws {
        XCTAssertEqual(imageDownloader.cachedImage(for: "http://www.example.com"), nil)
    }
    
    func testCachedImage() throws {

        let networkService = NetworkServiceMock<Data>()
        let expectedImage = UIImage(systemName: "questionmark.circle.fill")
        let imageData = try XCTUnwrap(expectedImage?.pngData())
        networkService.set(response: imageData)
        InjectedValues[\.networkService] = networkService
        
        let expectation = XCTestExpectation()
        Task {
            do {
                let _ = try await imageDownloader.downloadImage(for:"http://www.example.com")
                
                expectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssert(imageDownloader.cachedImage(for: "http://www.example.com") != nil)
    }
}
