import UIKit
import SnapKit
import RxSwift
import MarketKit

class MarketInfosController: UIViewController {
    private let tableView = UITableView()

    private var marketInfos = [MarketInfo]()
    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
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
        Singleton.instance.kit.marketInfosSingle(top: 250, currencyCode: "USD")
//        Singleton.instance.kit.advancedMarketInfosSingle(top: 250, currencyCode: "USD")
//        Singleton.instance.kit.marketInfosSingle(categoryUid: "blockchains", currencyCode: "USD")
//        Singleton.instance.kit.marketInfosSingle(coinUids: ["bitcoin", "tether"], currencyCode: "USD")
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] marketInfos in
                    self?.marketInfos = marketInfos
                    self?.tableView.reloadData()
                })
                .disposed(by: disposeBag)
    }

}

extension MarketInfosController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        marketInfos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: String(describing: MarketInfoCell.self), for: indexPath)
    }

}

extension MarketInfosController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MarketInfoCell {
            cell.bind(marketInfo: marketInfos[indexPath.row])
        }
    }

}
