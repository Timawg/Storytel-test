import Foundation

extension SearchResult.Item {
    var formattedAuthorNames: String? {
        if let authors,
           !authors.isEmpty {
            return "Authored by: \(authors.map(\.name).joined(separator: ", "))"
        } else {
            return nil
        }
    }
    
    var formattedNarratorNames: String? {
        if let narrators,
           !narrators.isEmpty {
            return "Narrated by: \(narrators.map(\.name).joined(separator: ", "))"
        } else {
            return nil
        }
    }
}

extension SearchResult.Item.Format.Cover {
    
    var isSquared: Bool {
        return width == height
    }
}
