import UIKit

class MainController: UITabBarController {

    init() {
        super.init(nibName: nil, bundle: nil)

        let marketSearchController = MarketSearchController()
        marketSearchController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)

        viewControllers = [
            UINavigationController(rootViewController: marketSearchController),
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
