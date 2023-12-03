import UIKit

class MainController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)

        let fullCoinsController = FullCoinsController()
        fullCoinsController.tabBarItem = UITabBarItem(title: "Full Coins", image: UIImage(systemName: "bitcoinsign.circle"), tag: 0)

        let marketCoinsController = MarketInfosController()
        marketCoinsController.tabBarItem = UITabBarItem(title: "Market Infos", image: UIImage(systemName: "bitcoinsign.circle.fill"), tag: 1)

        let categoryController = CoinCategoryController()
        categoryController.tabBarItem = UITabBarItem(title: "Categories", image: UIImage(systemName: "books.vertical"), tag: 2)

        let postsController = PostsController()
        postsController.tabBarItem = UITabBarItem(title: "Posts", image: UIImage(systemName: "newspaper"), tag: 3)

        let miscController = MiscController()
        miscController.tabBarItem = UITabBarItem(title: "Misc", image: UIImage(systemName: "menucard"), tag: 4)

        viewControllers = [
            UINavigationController(rootViewController: fullCoinsController),
            UINavigationController(rootViewController: marketCoinsController),
            UINavigationController(rootViewController: categoryController),
            UINavigationController(rootViewController: postsController),
            UINavigationController(rootViewController: miscController),
        ]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
