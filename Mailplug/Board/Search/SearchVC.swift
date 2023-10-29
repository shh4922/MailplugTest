import Combine
import Foundation
import UIKit

import SnapKit

class SearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var viewmodel = SearchVM()
    
    private var cancellable : Set<AnyCancellable> = []
    
    lazy var navbar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var img_search: UIImageView = {
        let image = UIImage(systemName: "magnifyingglass")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    lazy var lb_type: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "#757575")
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var tf_input: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "일반게시판에서 검색"
        textfield.font = .systemFont(ofSize: 16)
        return textfield
    }()
    
    lazy var btn_cancel: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(viewmodel, action: #selector(viewmodel.dismissView), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: RecentSearchCell.identifier)
        tableView.register(SearchingCell.self, forCellReuseIdentifier: SearchingCell.identifier)
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        setConstrain()
//        binding()
        
        tableView.dataSource = self
        tableView.delegate = self

        self.tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        binding()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellable.removeAll()
    }
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
}

//MARK: - layout

extension SearchVC {
    func addView() {
        view.addSubview(navbar)
        navbar.addSubview(img_search)
        navbar.addSubview(lb_type)
        navbar.addSubview(tf_input)
        view.addSubview(btn_cancel)
        view.addSubview(tableView)
        
    }
    
    func setConstrain() {
        navbar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(btn_cancel.snp.leading).offset(-10)
            make.height.equalTo(30)
        }
        
        img_search.snp.makeConstraints { make in
            make.centerY.equalTo(navbar)
            make.leading.equalTo(navbar).offset(20)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        lb_type.snp.makeConstraints { make in
            make.centerY.equalTo(navbar)
            make.leading.equalTo(img_search.snp.trailing).offset(1)
            make.size.equalTo(0)
        }
        
        tf_input.snp.makeConstraints { make in
            make.centerY.equalTo(navbar)
            make.leading.equalTo(lb_type.snp.trailing)
            make.trailing.equalTo(navbar.snp.trailing)
        }
        
        btn_cancel.snp.makeConstraints { make in
            make.centerY.equalTo(navbar)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.greaterThanOrEqualTo(navbar.snp.trailing).offset(4)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: - tableView

extension SearchVC: RecentSearchCellDelegate {
    
    func deleteCell(model: RecentSearchModel) {
        viewmodel.deleteCell()
    }
    
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    /// 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewmodel.tabCellEvent(index: indexPath.row)
    }

}

//MARK: - binding

extension SearchVC {
    func binding(){

        /// 현재 보여지는 게시판이름을 보여줌
        viewmodel.$currentBoard
            .receive(on: RunLoop.main)
            .sink {
                self.tf_input.placeholder = "\($0?.displayName ?? "")에서 검색"
            }
            .store(in: &cancellable)
        
        /// 검색완료시, searchType on
        viewmodel.$searchResult
            .receive(on: DispatchQueue.main)
            .sink {
                if $0 != nil {
                    self.lb_type.isHidden = false
                    self.lb_type.snp.updateConstraints { make in
                        make.height.equalTo(15)
                        make.width.equalTo(45)
                    }
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellable)
        
        /// 검색중일땐 searchType을 다시 hidden처리,
        /// 검색 input을 viewmodel에 있는 input에 넣어줌,
        /// 기존에 검색결과 데이터를 지워버림
        tf_input.publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                self.searchTypeHidden()
                self.viewmodel.input = $0
                self.viewmodel.searchResult = nil
            })
            .store(in: &cancellable)
        
        /// 최근검색이 업데이트될때 화면 다시로드
        viewmodel.$recentSearchs
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellable)
        
        ///최근검색에서 클릭시, 최근검색 content가 textField에 들어가기 위해
        viewmodel.$input
            .receive(on: RunLoop.main)
            .sink {
                self.tableView.reloadData() 
                self.tf_input.text = $0
                self.searchTypeHidden()
            }
            .store(in: &cancellable)
        
        ///searchType에 이벤트전송시, lb_type 변경
        viewmodel.$searchResult
            .receive(on: RunLoop.main)
            .sink { _ in
                self.lb_type.text = self.viewmodel.searchType
            }
            .store(in: &cancellable)
    }
    
    /// 검색수정 & 빈값일시, searchType 의 text를  안보이도록 히든
    func searchTypeHidden(){
        self.lb_type.isHidden = true
        self.lb_type.snp.updateConstraints { make in
            make.height.equalTo(0)
            make.width.equalTo(0)
        }
    }
}
