import MarketKit
import SnapKit
import UIKit

class CoinCategoryController: UIViewController {
    private let tableView = UITableView()

    private var coinCategories = [CoinCategory]()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Categories"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.register(CoinCategoryCell.self, forCellReuseIdentifier: String(describing: CoinCategoryCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        Task { [weak self] in
            self?.coinCategories = try await Singleton.instance.kit.coinCategories(currencyCode: "usd")
            self?.tableView.reloadData()
        }
    }
}

extension CoinCategoryController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        coinCategories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: String(describing: CoinCategoryCell.self), for: indexPath)
    }
}

extension CoinCategoryController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CoinCategoryCell {
            cell.bind(coinCategory: coinCategories[indexPath.row])
        }
    }
}
