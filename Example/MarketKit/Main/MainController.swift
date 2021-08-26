import UIKit

class MainController: UITabBarController {

    init() {
        super.init(nibName: nil, bundle: nil)

        let marketSearchController = MarketSearchController()
        marketSearchController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)

        let categoryController = CoinCategoryController()
        categoryController.tabBarItem = UITabBarItem(title: "Categories", image: UIImage(systemName: "books.vertical"), tag: 1)

        viewControllers = [
            UINavigationController(rootViewController: marketSearchController),
            UINavigationController(rootViewController: categoryController),
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
