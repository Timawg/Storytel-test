import Foundation

struct SearchResult: Decodable, Equatable {
    
    struct Item: Decodable, Equatable {
        static func == (lhs: SearchResult.Item, rhs: SearchResult.Item) -> Bool {
            return lhs.id == rhs.id && lhs.title == rhs.title
        }
        
        struct Contributor: Decodable, Equatable {
            let id: String
            let name: String
        }

        struct Format: Decodable, Equatable {
            static func == (lhs: SearchResult.Item.Format, rhs: SearchResult.Item.Format) -> Bool {
                return lhs.cover == rhs.cover
            }
            
            struct Cover: Decodable, Equatable {
                let url: String
                let width: Int
                let height: Int
            }
            
            let cover: Cover
        }
    
        let id: String
        let title: String
        let authors: [Contributor]?
        let narrators: [Contributor]?
        let formats: [Format]
    }
    
    let nextPageToken: String?
    let totalCount: Int
    let items: [Item]
}
