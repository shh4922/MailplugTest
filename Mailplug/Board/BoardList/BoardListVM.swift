import Combine
import Foundation

import Alamofire

class BoardListVM: ObservableObject {
    
    weak var coordinator: AppCoordinator?
    
    @Published var boardList : BoardListModel? = nil
    
    var cancellable : Set<AnyCancellable> = []
    
    init() {
        BoardService.share.$boardList
            .receive(on: DispatchQueue.main)
            .assign(to: \.boardList, on: self)
            .store(in: &cancellable)
    }
    
    @objc func dismissView(){
        print("run dismiss")
        coordinator?.dismiss()
    }
    
    func selectBoard(_ index: Int) {
        /// 현재 게시판 변경
        BoardService.share.board = BoardService.share.boardList?.value[index]

        /// 기존 post 초가화
        BoardService.share.posts = nil
        
        /// 게시판post 변경
        BoardService.share.fetchBoardPostList()
        
        /// 화면 닫음
        coordinator?.dismiss()
        
    }
}
