//
//  ResponseMockData.swift
//  StorytelAppTests
//
//  Created by Tim Gunnarsson on 2023-09-04.
//

import Foundation
@testable import StorytelApp

struct ReponseMockData {
    static let searchResult: SearchResult = {
        let contributor1 = SearchResult.Item.Contributor(id: "1", name: "John Doe")
        let contributor2 = SearchResult.Item.Contributor(id: "2", name: "Jane Smith")

        let format1 = SearchResult.Item.Format.init(cover: .init(url: "https://www.example.com", width: 620, height: 620))
        let format2 = SearchResult.Item.Format.init(cover: .init(url: "https://www.example.com", width: 420, height: 620))

        let items: [SearchResult.Item] = [
            SearchResult.Item(id: "1", title: "Audiobook 1", authors: [contributor1], narrators: nil, formats: [format1, format2]),
            SearchResult.Item(id: "2", title: "Audiobook 2", authors: [contributor1, contributor2], narrators: nil, formats: [format2, format1]),
            SearchResult.Item(id: "3", title: "Audiobook 3", authors: nil, narrators: [contributor1], formats: [format2]),
            SearchResult.Item(id: "4", title: "Audiobook 4", authors: nil, narrators: [contributor1, contributor2], formats: [format1])
        ]

        let searchResult = SearchResult(nextPageToken: "nextPageTokenValue", totalCount: 4, items: items)
        return searchResult
    }()
}
