import UIKit

import SnapKit
extension UITableView {
    func setRecentEmptyView() {
        let view = UIView()
        
        let label = UILabel()
        label.text = "게시글의 제목, 내용 또는 작성자에 포함된\n단어 또는 문장을 검색해 주세요."
        label.textColor = UIColor(named: "#757575")
        label.numberOfLines = 0
        
        let imageview = UIImageView(image: UIImage(named: "RecentSearchNil"))
        imageview.contentMode = .scaleAspectFit
        
        view.addSubview(imageview)
        view.addSubview(label)
        
        imageview.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp.top).offset(80)
            make.width.equalTo(110)
            make.height.equalTo(180)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageview.snp.bottom)
            make.centerX.equalTo(view)
        }
        self.backgroundView = view
    }
    
    func setSearchEmptyView() {
        let view = UIView()
        
        let label = UILabel()
        label.text = "검색 결과가 없습니다.\n 다른 검색어를 입력해 보세요."
        label.textColor = UIColor(named: "#757575")
        label.numberOfLines = 0
        
        let imageview = UIImageView(image: UIImage(named: "SearchNil"))
        imageview.contentMode = .scaleAspectFit
        
        view.addSubview(imageview)
        view.addSubview(label)
        
        imageview.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp.top).offset(80)
            make.width.equalTo(110)
            make.height.equalTo(180)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageview.snp.bottom)
            make.centerX.equalTo(view)
        }
        self.backgroundView = view
    }
    
    func setBoardPostEmptyView() {
        let view = UIView()
        
        let label = UILabel()
        label.text = "등록된 게시글이 없습니다."
        label.textColor = UIColor(named: "#757575")
        label.numberOfLines = 0
        
        let imageview = UIImageView(image: UIImage(named: "PostNil"))
        imageview.contentMode = .scaleAspectFit
        
        view.addSubview(imageview)
        view.addSubview(label)
        
        imageview.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp.top).offset(80)
            make.width.equalTo(100)
            make.height.equalTo(180)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageview.snp.bottom)
            make.centerX.equalTo(view.snp.centerX)
        }
        self.backgroundView = view
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
