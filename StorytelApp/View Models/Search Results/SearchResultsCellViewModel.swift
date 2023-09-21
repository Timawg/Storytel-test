//
//  SearchResultsCellViewModel.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-08-31.
//

import Foundation
import UIKit

struct SearchResultCellViewModel: Hashable {
    
    private typealias Cover = SearchResult.Item.Format.Cover

    private let uuid = UUID().uuidString
    @Injected(\.imageDownloader) private var imageDownloader: ImageDownloadingProtocol
    private let item: SearchResult.Item
    
    init(item: SearchResult.Item) {
        self.item = item
    }
    
    private var cover: Cover? {
        return item.formats.first(where: \.cover.isSquared)?.cover ?? item.formats.first?.cover
    }

    var imageAspectRatio: CGFloat {
        guard let height = cover?.height, let width = cover?.width else { return 1 }
        return CGFloat(width) / CGFloat(height)
    }
    
    var title: String {
        item.title
    }
    
    var authors: String {
        return item.formattedAuthorNames ?? ""
    }
    
    var narrators: String {
        return item.formattedNarratorNames ?? ""
    }
    
    func retrieveImage() async throws -> UIImage? {
        guard let coverUrlString = cover?.url else {
            throw URLError(.badURL)
        }
        
        return try await imageDownloader.downloadImage(for: coverUrlString)
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(uuid)
    }
    
    static func == (lhs: SearchResultCellViewModel, rhs: SearchResultCellViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
