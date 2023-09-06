import Foundation
import UIKit

protocol SearchResultsViewModelProtocol {
    var searchQuery: String { get set }
    var items: [SearchResult.Item] { get set }
    var nextItems: [SearchResult.Item] { get set }
    func performSearch() async throws -> [SearchResultCellViewModel]    
}

final class SearchResultsViewModel: SearchResultsViewModelProtocol {
    
    @Injected(\.networkService) private var networkService: NetworkServiceProtocol
    private var nextPageToken: String?
    private var isEndPageReached = false
    var searchQuery: String
    var items: [SearchResult.Item]
    var nextItems: [SearchResult.Item]
    
    init(
        nextPageToken: String? = nil,
        searchQuery: String = "Harry",
        items: [SearchResult.Item] = [],
        nextItems: [SearchResult.Item] = []
    ) {
        self.nextPageToken = nextPageToken
        self.searchQuery = searchQuery
        self.items = items
        self.nextItems = nextItems
    }
    
    func performSearch() async throws -> [SearchResultCellViewModel] {
        guard !isEndPageReached else {
            throw CancellationError()
        }

        let request = SearchRequest(query: searchQuery, nextPageToken: nextPageToken)
        let searchResult: SearchResult = try await networkService.perform(request: request)

        items.append(contentsOf: searchResult.items)
        nextItems = searchResult.items
        nextPageToken = searchResult.nextPageToken
        isEndPageReached = items.count >= searchResult.totalCount
        let viewModels = nextItems.map { SearchResultCellViewModel(item: $0) }
        return viewModels
    }
}
