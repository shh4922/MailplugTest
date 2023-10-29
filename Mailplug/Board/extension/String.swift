import Foundation

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
