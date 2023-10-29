import Combine
import UIKit
import Foundation

extension UITextField {
    var publisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            //NotificationCenter로 들어온 notification의 optional 타입 object 프로퍼티를 UITextField로 타입 캐스팅
            .compactMap{ $0.object as? UITextField}
            //text 프로퍼티만 가져오기
            .map{ $0.text ?? "" }    //값이 없는 경우 빈 문자열 반환
            .print()
            .eraseToAnyPublisher()
    }
}

