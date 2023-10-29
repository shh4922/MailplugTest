import Combine
import Foundation
import UIKit

import Alamofire
import SnapKit

class BoardVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var viewmodel = BoardVM()
    
    private var cancellable : Set<AnyCancellable> = []
    
    lazy var navbar: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var btn_menu: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "text.justify"), for: .normal)
        button.tintColor = .black
        button.addTarget(viewmodel, action: #selector(viewmodel.showBoardList), for: .touchUpInside)
        return button
    }()
    
    lazy var lb_boardName: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    lazy var btn_search: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .black
        button.addTarget(viewmodel, action: #selector(viewmodel.showSearchView), for: .touchUpInside)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,style: .plain)
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addView()
        setConstrain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        binding()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellable.removeAll()
    }
}

//MARK: - layout

extension BoardVC {
    func addView() {
        view.addSubview(navbar)
        navbar.addSubview(btn_menu)
        navbar.addSubview(lb_boardName)
        navbar.addSubview(btn_search)
        view.addSubview(tableView)
        
    }
    
    func setConstrain(){
        navbar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(18)
            make.horizontalEdges.equalToSuperview().inset(18)
            make.height.equalTo(34)
        }
        
        btn_menu.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(navbar.snp.top)
            make.size.equalTo(24)
        }
        
        lb_boardName.snp.makeConstraints { make in
            make.leading.equalTo(btn_menu.snp.trailing).offset(16)
            make.top.equalTo(navbar.snp.top)
        }
        
        btn_search.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.top)
            make.leading.greaterThanOrEqualTo(lb_boardName.snp.trailing).offset(50)
            make.trailing.equalToSuperview()
            make.size.equalTo(24)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: - Binding

extension BoardVC {
    func binding(){
        viewmodel.$currentBoard
            .receive(on: DispatchQueue.main)
            .sink { self.lb_boardName.text = $0?.displayName }
            .store(in: &cancellable)
        
        viewmodel.$currentBoardPosts
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
}

//MARK: - tableView Setting
extension BoardVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.currentBoardPosts?.value.count == 0 {
            tableView.setBoardPostEmptyView()
            return 0
        }
        return viewmodel.currentBoardPosts?.value.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.restore()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell ?? PostCell()
        if let post = viewmodel.currentBoardPosts?.value[indexPath.row] {
            cell.bind(post: post)
        }
        
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 사용자가 스크롤할 때 호출
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            // 스크롤이 테이블 뷰 아래로 도달하면 다음 페이지 로드
            viewmodel.paging()
        }
    }
    
}
