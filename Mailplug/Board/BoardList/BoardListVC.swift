import Combine
import UIKit
import Foundation

import SnapKit

class BoardListVC: UIViewController {
    
    var viewmodel = BoardListVM()
    
    private var cancellalbe : Set<AnyCancellable> = []
    
    lazy var btn_dismiss: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.addTarget(viewmodel, action: #selector(viewmodel.dismissView), for: .touchUpInside)
        return button
    }()
    
    lazy var lb_title: UILabel = {
        let label = UILabel()
        label.text = "게시판"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "#241E17")
        return label
    }()
    
    lazy var lb_divider: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,style: .plain)
        tableView.register(BoardCell.self, forCellReuseIdentifier: BoardCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        bind()
        addView()
        setConstrain()
        
    }
    
}

//MARK: - tableView init

extension BoardListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.boardList?.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BoardCell.identifier, for: indexPath) as! BoardCell
        cell.boardName.text = viewmodel.boardList?.value[indexPath.row].displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewmodel.selectBoard(indexPath.row)
    }
}

//MARK: - layout

extension BoardListVC {
    
    func addView(){
        view.addSubview(btn_dismiss)
        view.addSubview(lb_title)
        view.addSubview(lb_divider)
        view.addSubview(tableView)
    }
    
    func setConstrain(){
        
        btn_dismiss.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().inset(18)
            make.size.equalTo(24)
        }
        
        lb_title.snp.makeConstraints { make in
            make.top.equalTo(btn_dismiss.snp.bottom).offset(14)
            make.leading.equalToSuperview().inset(18)
            make.bottom.lessThanOrEqualTo(view.snp.bottom).offset(30)
        }
        
        lb_divider.snp.makeConstraints { make in
            make.top.equalTo(lb_title.snp.bottom).offset(14)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(0.2)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(lb_divider.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: - Binding

extension BoardListVC {
    func bind(){
        self.viewmodel.$boardList
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellalbe)
    }
}
