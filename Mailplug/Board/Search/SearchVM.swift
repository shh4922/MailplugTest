import Combine
import UIKit
import CoreData

import Alamofire

enum SearchTypeEnum: String {
    case all = "전체"
    case title = "제목"
    case contents = "내용"
    case writer = " 작성자"
}

enum CellType {
    case postCell
    case searchingCell
    case recentCell
    case postIsNil
    case rescentIsNil
}

class SearchVM: ObservableObject {
    
    weak var coordinator: AppCoordinator?
    
    /// 검색중 나오는 [ 전체, 제목, 내용, 작성자 ]
    let list: [SearchTypeEnum] = [.all, .contents, .title, .writer]
    
    /// 검색input & searchType
    @Published var input = ""
    @Published var searchType = ""
    
    /// 최근검색리스트(필수)
    @Published var recentSearchs : [RecentSearchModel] = []
    
    /// 현재 보고있는 게시판 정보 (필수)
    @Published var currentBoard: Board?
    
    /// 검색결과를 담을 곳 (필수)
    @Published var searchResult: BoardModel? = nil
    
    private var cancellable: Set<AnyCancellable> = []

    init() {
        /// fetch 최근검색
        CoreDataManager.shared.getRecentSearch()
        
        /// 최근검색 구독 -> 해지해줄필요없
        CoreDataManager.shared.$recentSearchs
            .receive(on: RunLoop.main)
            .assign(to: \.recentSearchs, on: self)
            .store(in: &cancellable)
        
        /// 현재 게시판 구독
        BoardService.share.$board
            .receive(on: RunLoop.main)
            .assign(to: \.currentBoard, on: self)
            .store(in: &cancellable)
    }
    
    /// 검색
    /// searchType을 따로받는이유
    /// coreData에 저장된 최근검색은 searchType을 한글로 [전체, 제목, 내용, 작성자] 이렇게 저장해주었기에
    /// 검색은 따로 조건에 30개씩 받으라는 말이없었기에, 받는즉시 덮어쓰기로 저장함
    func searchPostList(type: SearchTypeEnum) {
        
        /// CoreData 에 검색내역 저장
        CoreDataManager.shared.saveORUpdate(RecentSearchModel(searchType: type.rawValue, content: input, searchTime: Date()))
        
        let url = "https://mp-dev.mail-server.kr/api/v2/boards/\(currentBoard?.boardId ?? 0)/posts?search=\(input)&searchTarget=\(type)&offset=&limit="

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
                self?.searchResult = decodeData
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func dismissView(){
        coordinator?.pop()
    }
}

//MARK: -  tableView Cell 관련

extension SearchVM {
    
    func deleteCell() {
        print("SearchVM - deleteCell()!!")
    }
    
    /// Cell 클릭
    func tabCellEvent(index: Int) {
        
        /// 최근검색에서 cell을 클릭시,
        if input.isEmpty {
            /// 셀의 위치 찾음
            let setList = recentSearchs[index]
            
            /// 해당 셀의 searchType 저장 -> 검색결과의 searchType에 searchType을 보여줘야하기때문.
            guard let type = SearchTypeEnum(rawValue: setList.searchType) else { return }
            
            /// 해당 셀의 content 를 input에 저장 -> api요청시, 에 영향을 받기때문
            input = setList.content
            searchType = setList.searchType
            
            /// 요청
            searchPostList(type: type)
            
            return
        }else {
            /// 검색한 input의 searchType을 지정함
            searchType = list[index].rawValue
            
            /// 검색해서 클릭시
            searchPostList(type: list[index])
        }
    }
    
    /// 셀의개수 구하는 함수
    func returnCellCount() -> Int {
        if input.isEmpty {
            if recentSearchs.isEmpty { return 0 }
            return recentSearchs.count
        }else{
            if searchResult == nil { return 4 }
            if searchResult?.value.count == 0 { return 0 }
            return searchResult?.value.count ?? 0
        }
    }
    
    /// cell종류 리턴
    func returnCellType() -> CellType {
        if input.isEmpty {
            if recentSearchs.isEmpty { return CellType.rescentIsNil }
            return CellType.recentCell
        }else{
            if searchResult == nil { return CellType.searchingCell }
            if searchResult?.value.count == 0 { return CellType.postIsNil }
            return CellType.postCell
        }
    }

}
