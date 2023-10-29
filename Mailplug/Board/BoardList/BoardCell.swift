import Foundation
import UIKit

import SnapKit

class BoardCell : UITableViewCell {
    
    static let identifier = "BoardCell"
    
    lazy var boardName: UILabel = {
        let label = UILabel()
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
    
}

//MARK: - layout

extension BoardCell {
    
    func addView() {
        self.addSubview(boardName)
    }
    
    func setLayout(){
        boardName.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2)
            make.horizontalEdges.equalToSuperview().inset(18)
        }
    }
}
