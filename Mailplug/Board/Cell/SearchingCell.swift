import Combine
import UIKit

import SnapKit

class SearchingCell: UITableViewCell {
    
    static let identifier = "SearchingCell"
    
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
    
    lazy var img_next: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "chevron.forward"))
        image.contentMode = .scaleAspectFit
        image.tintColor = UIColor(named: "#757575")
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addView()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchingCell {
    func addView() {
        contentView.addSubview(img_timer)
        contentView.addSubview(lb_type)
        contentView.addSubview(lb_content)
        contentView.addSubview(img_next)
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
            make.trailing.lessThanOrEqualTo(img_next.snp.leading).offset(3)
        }
        
        img_next.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.size.equalTo(18)
        }
    }
}
