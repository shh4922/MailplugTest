# MailplugTest

## 프로젝트 구조

![스크린샷 2023-10-29 오후 10.06.18.png](iOS%20%E1%84%89%E1%85%A1%E1%84%8C%E1%85%A5%E1%86%AB%E1%84%80%E1%85%AA%E1%84%8C%E1%85%A6%20a3a4b390bed943e39ad221988b3cec80/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2023-10-29_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_10.06.18.png)

---

## 사용 툴 & 버전

| OS 버전 | macOS 14.0 |
| --- | --- |
| xcode 버전 | 15.0.1 |
| 디자인패턴 | mvvm + coordinator |
| 비동기 | Combine |
| 의존성 관리 도구 | SPM |
| UI  | uikit |
| network | alamofire (5.8.0) |
| autolayout | Snapkit (5.6.0) |
| localDB | CoreData |

---

## 소스 설명

### SceneDelegate

- 앱이 실행시 게시판리스트를 가져옵니다.
- coordinator의 start를 시작합니다.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
				/// fetch 게시판리스트
        BoardService.share.fetchBoardList()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let navigationController = UINavigationController()
        
        coordinator = AppCoordinator(navigationController: navigationController)
        coordinator?.start()
        
        window = UIWindow(windowScene: windowScene)
                
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
    }
```

---

### Coordinator

- 게시물선택은 present 화면
- 검색의 경우 navigation

```swift
import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        /// 첫시작은 BoardVC 차후 로그인/ 자동로그인 유무에 따라 조건추가 가능
        showBoardVC()
    }
    
    func showBoardVC() {
        let vc = BoardVC()
        vc.viewmodel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showBoardListVC() {
        let vc = BoardListVC()
        vc.viewmodel.coordinator = self
        navigationController.present(vc, animated: true)
    }
    
    func showSearchVC() {
        let vc = SearchVC()
        vc.viewmodel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func dismiss(){
        navigationController.dismiss(animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
}
```

---


### BoardService.swift

- fetchBoardList 의 경우 앱실행후 딱 한번 수행
- 게시판의 첫화면은 응답으로 온 게시판들중 첫번째로 저장
    - 게시판 변경시, 탭한 셀의 index 번호를 통해 게시판은 변경
- 게시판의 게시물을 요청합니다.
- posts의 경우 30개씩 페이징 처리
    - nil 일시 단순저장합니다.
    - nil 이 아닐시, 기존 데이터에 새로운데이터를 더해줍니다.

```swift
/// BoardService

/// 싱글톤
static let share = BoardService()
    
/// 서버에있는 게시판 리스트
@Published var boardList: BoardListModel?
    
/// 현재 게시판
@Published var board : Board?
    
/// 게시판 Post
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
```

---


### 게시판리스트 ( BoardList)

**init**

- Service 에 있는 게시판리스트를 구독합니다.
- 화면에선 구독한 게시판 리스트를 보여줍니다.

```swift
/// BoardListVM

@Published var boardList : BoardListModel? = nil

init() {
        BoardService.share.$boardList
            .receive(on: DispatchQueue.main)
            .assign(to: \.boardList, on: self)
            .store(in: &cancellable)
    }
```

**게시판 선택시**

- 게시판 변경시, 선택된 index 의 게시판으로 변경을 Service 에 요청합니다
- 게시판에 따라 post 가 다르므로  post 는 초기화후 다시 받아옵니다.

```swift
/// BoardListVM

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
```

---


### 게시판 (Board)

**init**

- 현재 게시판이 무엇인지 알기위해 Service 에 있는 현재게시판을 구독합니다
- post 또한 Service 에 저장해두었기에 구독하여 가져옵니다.

```swift
/// BoardVM

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
```

**30개씩 paging 처리** 

- 다음조건을 만족시, offset을 현재 가지고있는 post의 개수로 지정해줍니다.
- 그후 다시 요청을 보냅니다.

```swift
/// BoardVC

func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 사용자가 스크롤할 때 호출
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            // 스크롤이 테이블 뷰 아래로 도달하면 다음 페이지 로드
            viewmodel.paging()
        }
    }
```

```swift
/// BoardVM

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
```

**게시물 Empty 화면**

- post의 개수가 0 일시 tableView의 background에 빈 뷰를 나오게 하였습니다.

```swift
/// BoardVC

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.currentBoardPosts?.value.count == 0 {
            tableView.setBoardPostEmptyView()
            return 0
        }
        return viewmodel.currentBoardPosts?.value.count ?? 0
        
    }
```

**yy-dd-mm 으로 표기**

- String에 확장하여 함수로 두었습니다.

```swift
extension String {
    func dateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "yy-MM-dd"
            return dateFormatter.string(from: date)
        } else {
            return "알수없음"
        }
    }
}
```

---


### 최근검색

- 최근검색의 경우 CoreData를 사용하여 구현하였습니다.
- 검색내역을 최신순으로 정렬해야 하기때문에 중복된 내용을 검색할경우 시간을 업데이트 하도록 하였습니다.
- 내용과 searchType 이 모두 같아야 중복된 내용으로 간주되기때문에, CoreDataModel에  content + searchType 을 sumTypeContent 이라고 만들어 주었으며
sumTypeContent를 사용하여 중복여부를 판단하였습니다.
- 또한 최근검색순서로 정렬해야 하기에 fetch 시, 정렬하도록 하였습니다.

```swift
/// CoreDataManager

static var shared = CoreDataManager()
    
@Published var recentSearchs: [RecentSearchModel] = []

/// get 최근검색
    func getRecentSearch() {
        var mySearchs: [RecentSearchModel] = []
        let fetchResults = fetchRecentSearch()
        for result in fetchResults {
            let recentSearch = RecentSearchModel(searchType: result.searchType ?? "", content: result.content ?? "", searchTime: result.searchTime ?? Date())
            mySearchs.append(recentSearch)
        }
        mySearchs.sort(by: { $0.searchTime > $1.searchTime})
        self.recentSearchs = mySearchs
    }
```

**최근검색 insert & update**

```swift
/// CoreDataManager

func saveORUpdate(_ recentSearch: RecentSearchModel) {
        guard let entity = entity else { return }
        let filter = filterSameData(sumTypeContent: recentSearch.sumTypeContent)
        do {
            let datas = try context.fetch(filter) as! [NSManagedObject] /// datas에는 만약 똑같은 키워드를 가진 데이터가 있다면 값이 담기고 없다면 빈배열이 담깁니다
            var cell: RecentSearch! = nil
            if datas.count == 0 { // 검색된 데이터가 없는경우
                cell = NSManagedObject(entity: entity, insertInto: context) as? RecentSearch /// 새로운 셀생성
            } else { /// 검색된 데이터가 있는경우 검색된 데이터를 호출
                cell = datas.first as? RecentSearch
            }
            cell.content = recentSearch.content
            cell.searchTime = recentSearch.searchTime
            cell.searchType = recentSearch.searchType
            cell.sumTypeContent = recentSearch.sumTypeContent
        } catch {
            print("Failed")
        }
				
				/// 저장
        saveToContext()
				
				/// 다시 get해서 초기화
        getRecentSearch()
    }

...
...

extension CoreDataManager {

    /// 중복된 데이터를 찾음
    fileprivate func filterSameData(sumTypeContent: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentSearch")
        fetchRequest.predicate = NSPredicate(format: "sumTypeContent = %@", "\(sumTypeContent)")
        return fetchRequest
    }
}
```

**최근검색 delete**

```swift
/// CoreDataManager

/// delete 최근검색
    func deleteRecentSearch(_ recentSearch: RecentSearchModel) {
        let fetchResults = fetchRecentSearch()
				
				/// sumTypeContent 가 같은것을 지움
        let recentSearchCell = fetchResults.filter { $0.sumTypeContent == recentSearch.sumTypeContent }
        context.delete(recentSearchCell[0])
        self.recentSearchs.removeAll { $0.sumTypeContent == recentSearch.sumTypeContent }
        saveToContext()
    }
```

---


### 검색

**init**

- 최근검색을 fetch 하여 초기화합니다.
- 최근검색 데이터를 구독하여 가져옵니다.
- 검색창에 현재 게시판의 정보를 보여줘야하기에 Service 에 있는 현재게시판 을 구독합니다.

```swift
/// SearchVM

enum SearchTypeEnum: String {
    case all = "전체"
    case title = "제목"
    case contents = "내용"
    case writer = " 작성자"
}

		/// 검색중 나오는 [ 전체, 제목, 내용, 작성자 ]
    let list: [SearchTypeEnum] = [.all, .contents, .title, .writer]
    
    /// navBar에 보여질 검색input & searchType
    @Published var input = ""
    @Published var searchType = ""
    
    /// 최근검색리스트(필수)
    @Published var recentSearchs : [RecentSearchModel] = []
    
    /// 현재 보고있는 게시판 정보 (필수)
    @Published var currentBoard: Board?
    
    /// 검색결과를 담을 곳 (필수)
    @Published var searchResult: BoardModel? = nil

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
```

**검색이벤트 요청**

- 검색완료후, 검색창에는 input 과 searchType 을 보여줘야합니다.
- 요청을 보내는방법에는 두가지가 있습니다.
두가지를 판단하는 기준을 input 에 값이 있냐없냐 로 판단했습니다.
    - (1) 검색후 4개의 cell 중 하나를 클릭
        - 검색의 셀은 4개로 고정되어있어 searchType = list[선택한index] 로 정의했습니다.
        - input의 경우 검색시 자동으로 초기화해주기에 따로 설정 X
    - (2) 최근검색에서 cell 을 클릭하는방법
        - recentSearchs[선택한index] 를 통해 몇번째인덱스 인지 찾습니다.
        - 선택한 index에 저장된 content 와, searchType 을 넣습니다.

```swift
/// SearchVM

...
...

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
```

**검색**

- 검색시 coreData에 저장합니다.
- coreData에선 자동으로 중복된것은 update,

```swift
/// SearchVM

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
```

**검색화면** 

- tableView 에 보여줄 화면 종류는 5가지입니다.
    - 최근검색 Cell
    - 최근검색 없는 화면
    - postCell
    - post 결과 없는 화면
    - 검색중 일때 의 Cell

```swift
///SearchVC

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// 개수가 0일때
        if viewmodel.returnCellCount() == 0 {
            
            if viewmodel.searchResult == nil { // 검색해서 나온 Post가 0개일 경우
                tableView.setRecentEmptyView()
            }else{
                tableView.setSearchEmptyView() // 최근검색이 0개일 경우
            }
        }else{
            return viewmodel.returnCellCount()
        }
        return 0
    }
```

```swift
///SearchVM

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
```

**검색화면에 보여줄 셀 화면**

- 최근검색에서 cell 을 클릭시 input은 비어있으므로, input의 여부에 따라 어떤Cell인지 판단하였습니다.
- 또한 최근검색의 경우 삭제가 가능하기에, delegate 를 사용하여 button 에 대한 이벤트를 위임 해 주었습니다.

```swift
/// SearchVC

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기존 Empty뷰 clear
        tableView.restore()
        
        switch viewmodel.returnCellType() {
        
        case .postCell:
            lb_type.text = viewmodel.searchType
            let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell ?? PostCell()
            if let post = viewmodel.searchResult?.value[indexPath.row] { cell.bind(post: post) }
            
            return cell
            
        case .recentCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchCell.identifier, for: indexPath) as? RecentSearchCell ?? RecentSearchCell()
            cell.bind(model: Array(viewmodel.recentSearchs)[indexPath.row])
            cell.cellDelegate = self
            return cell
            
        case .searchingCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchingCell.identifier, for: indexPath) as? SearchingCell ?? SearchingCell()
            cell.lb_type.text = viewmodel.list[indexPath.row].rawValue
            cell.lb_content.text = viewmodel.input
            tableView.delegate = self
            return cell
            
        case .postIsNil:
            print("post Is Nil")
        case .rescentIsNil:
            print("recentSearch Is Nil")
            
        }
        
        let cell = UITableViewCell()
        return cell
    }
```

```swift
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
```
