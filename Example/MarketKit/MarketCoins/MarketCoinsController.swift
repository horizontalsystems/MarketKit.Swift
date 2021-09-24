import UIKit
import SnapKit
import RxSwift
import MarketKit

class MarketCoinsController: UIViewController {
    private let tableView = UITableView()

    private var marketCoins = [MarketCoin]()
    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Market Coins"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.register(MarketCoinCell.self, forCellReuseIdentifier: String(describing: MarketCoinCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        syncCoins()
    }

    private func syncCoins() {
        Singleton.instance.kit.marketCoinsSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] marketCoins in
                    self?.marketCoins = marketCoins
                    self?.tableView.reloadData()
                })
                .disposed(by: disposeBag)
    }

}

extension MarketCoinsController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        marketCoins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: String(describing: MarketCoinCell.self), for: indexPath)
    }

}

extension MarketCoinsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MarketCoinCell {
            cell.bind(marketCoin: marketCoins[indexPath.row])
        }
    }

}
