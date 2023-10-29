import Combine
import UIKit

import SnapKit

protocol RecentSearchCellDelegate: AnyObject {
    func deleteCell(model: RecentSearchModel)
}

class RecentSearchCell: UITableViewCell {
    
    static let identifier = "RecentSearchCell"
    
    var viewmodel: RecentSearchCellVM?
    
    weak var cellDelegate: RecentSearchCellDelegate?
    
    lazy var img_timer: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "timer"))
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    lazy var lb_type: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "#757575")
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var lb_content: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var btn_cancel: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(named: "#757575")
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addView()
        setLayout()
//        viewmodel?.cellDelegate = self.cellDelegate
        self.btn_cancel.addTarget(self, action: #selector(deleteCell), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Layout

extension RecentSearchCell {
    func addView() {
        contentView.addSubview(img_timer)
        contentView.addSubview(lb_type)
        contentView.addSubview(lb_content)
        contentView.addSubview(btn_cancel)
    }
    
    func setLayout() {
        img_timer.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.size.equalTo(24)
        }
        
        lb_type.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(img_timer.snp.trailing).offset(5)
        }
        
        lb_content.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(lb_type.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualTo(btn_cancel.snp.leading).offset(3)
        }
        
        btn_cancel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.size.equalTo(18)
        }
    }
}

//MARK: - bind

extension RecentSearchCell {
    func bind(model: RecentSearchModel){
        viewmodel = RecentSearchCellVM(recentSearch: model)
        lb_content.text = viewmodel?.recentSearch.content
        lb_type.text = viewmodel?.recentSearch.searchType
    }
    
    @objc func deleteCell() {
        guard let model = viewmodel?.recentSearch else { return }
        CoreDataManager.shared.deleteRecentSearch(model)
    }
}
