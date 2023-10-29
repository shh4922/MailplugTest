import Combine
import Foundation

class RecentSearchCellVM: ObservableObject {
    
    @Published var recentSearch: RecentSearchModel
    
    init(recentSearch: RecentSearchModel) {
        self.recentSearch = recentSearch
    }
}
