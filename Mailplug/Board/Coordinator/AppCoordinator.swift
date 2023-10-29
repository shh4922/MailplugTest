import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        /// 첫시작은 BoardVC 차후 로그인/ 자동로그인 유무에 따라 조건추가 가능
        showBoardVC()
    }
    
    func showBoardVC() {
        let vc = BoardVC()
        vc.viewmodel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showBoardListVC() {
        let vc = BoardListVC()
        vc.viewmodel.coordinator = self
        navigationController.present(vc, animated: true)
    }
    
    func showSearchVC() {
        let vc = SearchVC()
        vc.viewmodel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func dismiss(){
        navigationController.dismiss(animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
}
