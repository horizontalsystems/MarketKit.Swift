import MarketKit
import SnapKit
import UIKit

class MarketInfosController: UIViewController {
    private let tableView = UITableView()

    private var marketInfos = [MarketInfo]()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Market Infos"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.register(MarketInfoCell.self, forCellReuseIdentifier: String(describing: MarketInfoCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        syncCoins()
    }

    private func syncCoins() {
        Task { [weak self] in
            self?.marketInfos = try await Singleton.instance.kit.marketInfos(top: 250, currencyCode: "USD", apiTag: "demo-app")
            self?.tableView.reloadData()
        }
    }
}

extension MarketInfosController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        marketInfos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: String(describing: MarketInfoCell.self), for: indexPath)
    }
}

extension MarketInfosController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MarketInfoCell {
            cell.bind(marketInfo: marketInfos[indexPath.row])
        }
    }
}
