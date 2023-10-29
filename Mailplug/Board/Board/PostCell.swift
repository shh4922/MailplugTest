import Foundation
import UIKit

import SnapKit

enum PostTypeEnum: String {
    case nomal = "normal"
    case reply = "reply"
    case notice = "notice"
}

class PostCell : UITableViewCell {
    
    static let identifier = "PostCell"
    
    lazy var lb_postType: CustomLabel = {
        let label = CustomLabel()
        label.backgroundColor = .orange
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 12,weight: .semibold)
        return label
    }()
    
    lazy var lb_title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var img_attachment: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "link"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(named: "#9E9E9E")
        return imageView
    }()
    
    lazy var lb_newPost: CustomLabel = {
        let label = CustomLabel()
        
        label.backgroundColor = UIColor(named: "#DB470D")
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 10)
        
        label.text = "N"
        label.backgroundColor = .red
        return label
    }()
    
    lazy var lb_writer: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "#9E9E9E")
        return label
    }()
    
    lazy var lb_createDateTime: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "#9E9E9E")
        return label
    }()
    
    lazy var img_viewCount: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "eye"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(named: "#9E9E9E")
        return imageView
    }()
    
    lazy var lb_viewCount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "#9E9E9E")
        return label
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lb_postType.text = ""
        lb_postType.snp.remakeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(17) // 원하는 위치로 설정
            make.leading.equalTo(contentView.snp.leading).offset(16)
        }
        
        img_attachment.isHidden = true
        img_attachment.snp.updateConstraints { make in
            make.size.equalTo(16)
        }
        
        lb_newPost.isHidden = true
        lb_newPost.snp.updateConstraints { make in
            make.size.equalTo(5)
        }
    }
    
    deinit {
        print("postCell deinit!!")
    }
}

//MARK: - layout

extension PostCell {
    
    func addView() {
        contentView.addSubview(lb_postType)
        contentView.addSubview(lb_title)
        contentView.addSubview(img_attachment)
        contentView.addSubview(lb_newPost)
        
        contentView.addSubview(lb_writer)
        contentView.addSubview(lb_createDateTime)
        contentView.addSubview(img_viewCount)
        contentView.addSubview(lb_viewCount)
    }
    
    func setLayout(){
        lb_postType.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.top.equalTo(contentView.snp.top).offset(17)
        }
        
        lb_title.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(17)
            make.leading.equalTo(lb_postType.snp.trailing).offset(2)
        }
        
        img_attachment.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(17)
            make.leading.equalTo(lb_title.snp.trailing).offset(4)
            make.size.equalTo(16)
        }
        
        lb_newPost.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(17)
            make.leading.equalTo(img_attachment.snp.trailing).offset(4)
            make.trailing.lessThanOrEqualTo(contentView.snp.trailing).offset(16)
            make.size.equalTo(5)
        }
        
        lb_writer.snp.makeConstraints { make in
            make.top.equalTo(lb_title.snp.bottom).offset(3)
            make.leading.equalTo(contentView.snp.leading).offset(16)
        }
        
        lb_createDateTime.snp.makeConstraints { make in
            make.top.equalTo(lb_title.snp.bottom).offset(3)
            make.leading.equalTo(lb_writer.snp.trailing).offset(3)
        }
        
        img_viewCount.snp.makeConstraints { make in
            make.top.equalTo(lb_title.snp.bottom).offset(3)
            make.leading.equalTo(lb_createDateTime.snp.trailing).offset(3)
            make.size.equalTo(16)
        }
        
        lb_viewCount.snp.makeConstraints { make in
            make.top.equalTo(lb_title.snp.bottom).offset(3)
            make.leading.equalTo(img_viewCount.snp.trailing)
            make.trailing.lessThanOrEqualTo(contentView.snp.trailing).offset(16)
        }
    }
    
    
}


extension PostCell {
    
    func bind(post: Post) {
        
        lb_postType.text = post.postType
        if post.postType == "notice" {
            lb_postType.backgroundColor = .orange
        }else if post.postType == "reply" {
            lb_postType.backgroundColor = .black
        }else{
            lb_postType.snp.remakeConstraints { make in
                make.top.equalTo(contentView.snp.top).offset(17) // 원하는 위치로 설정
                make.leading.equalTo(contentView.snp.leading).offset(16)
                make.width.equalTo(0)
                make.height.equalTo(0)
            }
        }
        
        
        lb_title.text = post.title
        
        if !(post.hasInlineImage) {
            img_attachment.isHidden = true
            img_attachment.snp.updateConstraints { make in
                make.size.equalTo(0)
            }
        }
        
        if !post.isNewPost {
            lb_newPost.isHidden = true
            lb_newPost.snp.updateConstraints { make in
                make.size.equalTo(0)
            }
        }
        
        lb_writer.text = post.writer.displayName
        
        lb_createDateTime.text = post.createdDateTime.dateFormat()
        
        
        lb_viewCount.text = "\(post.viewCount)"
    }
}
