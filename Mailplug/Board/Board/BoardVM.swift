import Foundation
import Combine

class BoardVM: ObservableObject{
    
    weak var coordinator : AppCoordinator?
    
    @Published var currentBoard : Board?
    
    @Published var currentBoardPosts: BoardModel?
    
    var cancellable : Set<AnyCancellable> = []
    
    init() {
        BoardService.share.$board
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentBoard, on: self)
            .store(in: &cancellable)
        
        BoardService.share.$posts
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentBoardPosts, on: self)
            .store(in: &cancellable)
    }
    
    /// paging
    func paging() {
        /// offset - 시작번호
        /// limit - 제한 개수
        /// total - 해당 post의 최대 개수
        guard let currentBoardPosts = currentBoardPosts else { return }
        
        if currentBoardPosts.total > currentBoardPosts.offset + currentBoardPosts.count {
            
            BoardService.share.posts?.offset = BoardService.share.posts?.value.count ?? 0
            
            BoardService.share.fetchBoardPostList()
        }
    }
    
    @objc func showBoardList() {
        coordinator?.showBoardListVC()
    }
    
    @objc func showSearchView() {
        coordinator?.showSearchVC()
    }
}

