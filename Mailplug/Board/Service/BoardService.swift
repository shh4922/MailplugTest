import Combine
import Foundation

import Alamofire

class BoardService {
    static let share = BoardService()
    
    @Published var boardList: BoardListModel?
    
    @Published var board : Board?
    
    @Published var posts: BoardModel?
    
    func fetchBoardList(){
        let url = "https://mp-dev.mail-server.kr/api/v2/boards"
        
        let headers : HTTPHeaders = [
            "Authorization":"Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODgxMDM5NDAsImV4cCI6MCwidXNlcm5hbWUiOiJtYWlsdGVzdEBtcC1kZXYubXlwbHVnLmtyIiwiYXBpX2tleSI6IiMhQG1wLWRldiFAIyIsInNjb3BlIjpbImVhcyJdLCJqdGkiOiI5MmQwIn0.Vzj93Ak3OQxze_Zic-CRbnwik7ZWQnkK6c83No_M780"]
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   headers: headers)
        .response { [weak self] response in
            switch response.result{
            case .success(let data):
                guard let data = data,
                      let decodeData = try? JSONDecoder().decode(BoardListModel.self, from: data) else { return }
                
                /// 게시판들 등록
                self?.boardList = decodeData

                /// 현재 보여질 게시판
                self?.board = self?.boardList?.value[0]
                
                /// 현재보여질 게시판의 post들 요청
                self?.fetchBoardPostList()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func fetchBoardPostList(){
        
        let url = "https://mp-dev.mail-server.kr/api/v2/boards/\(board?.boardId ?? 0)/posts?offset=\(posts?.offset ?? 0)&limit=30"
        
        let headers : HTTPHeaders = [
            "Authorization":"Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODgxMDM5NDAsImV4cCI6MCwidXNlcm5hbWUiOiJtYWlsdGVzdEBtcC1kZXYubXlwbHVnLmtyIiwiYXBpX2tleSI6IiMhQG1wLWRldiFAIyIsInNjb3BlIjpbImVhcyJdLCJqdGkiOiI5MmQwIn0.Vzj93Ak3OQxze_Zic-CRbnwik7ZWQnkK6c83No_M780"]
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   headers: headers)
        .response { [weak self] response in
            switch response.result {
            case .success(let data):
                guard let data = data,
                      let decodeData = try? JSONDecoder().decode(BoardModel.self, from: data) else { return }
                
                if self?.posts == nil {
                    self?.posts = decodeData
                }else {
                    self?.posts?.value += decodeData.value
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}
