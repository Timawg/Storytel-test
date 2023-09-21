import Foundation
import UIKit

protocol SearchResultsViewModelProtocol {
    var searchQuery: String { get set }
    var items: [SearchResult.Item] { get set }
    func performSearch() async throws -> [SearchResultCellViewModel]
    func performSearch(query: String) async throws -> [SearchResultCellViewModel]
}

final class SearchResultsViewModel: SearchResultsViewModelProtocol {

    @Injected(\.networkService) private var networkService: NetworkServiceProtocol
    private var nextPageToken: String?
    private var isEndPageReached = false
    var searchQuery: String
    var items: [SearchResult.Item]
    
    init(
        nextPageToken: String? = nil,
        searchQuery: String = "Harry",
        items: [SearchResult.Item] = []
    ) {
        self.nextPageToken = nextPageToken
        self.searchQuery = searchQuery
        self.items = items
    }
    
    @MainActor
    func performSearch(query: String) async throws -> [SearchResultCellViewModel] {

        let request = SearchRequest(query: query, nextPageToken: nextPageToken)
        let searchResult: SearchResult = try await networkService.perform(request: request)

        items.append(contentsOf: searchResult.items)
        nextPageToken = searchResult.nextPageToken
        searchQuery = query
        isEndPageReached = items.count >= searchResult.totalCount
        let viewModels = searchResult.items.map { SearchResultCellViewModel(item: $0) }
        return viewModels
    }
    
    @MainActor
    func performSearch() async throws -> [SearchResultCellViewModel] {
        guard !isEndPageReached else {
            throw CancellationError()
        }

        let request = SearchRequest(query: searchQuery, nextPageToken: nextPageToken)
        let searchResult: SearchResult = try await networkService.perform(request: request)

        items.append(contentsOf: searchResult.items)
        nextPageToken = searchResult.nextPageToken
        isEndPageReached = items.count >= searchResult.totalCount
        let viewModels = searchResult.items.map { SearchResultCellViewModel(item: $0) }
        return viewModels
    }
}
