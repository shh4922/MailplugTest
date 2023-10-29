import Foundation

struct RecentSearchModel: Hashable {
    let searchType: String
    let content: String
    let searchTime: Date
    
    var sumTypeContent: String {
        return searchType + content
    }
}
