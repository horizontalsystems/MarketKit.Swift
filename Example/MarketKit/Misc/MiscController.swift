import UIKit
import SnapKit
import RxSwift
import MarketKit

class MiscController: UIViewController {
    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Misc"
        view.backgroundColor = .groupTableViewBackground

        let coinPricesButton = UIButton()

        view.addSubview(coinPricesButton)
        coinPricesButton.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            maker.centerX.equalToSuperview()
        }

        coinPricesButton.setTitle("Coin Prices", for: .normal)
        coinPricesButton.setTitleColor(.systemBlue, for: .normal)
        coinPricesButton.addTarget(self, action: #selector(onTapCoinPrices), for: .touchUpInside)

        let coinHistoricalPriceButton = UIButton()

        view.addSubview(coinHistoricalPriceButton)
        coinHistoricalPriceButton.snp.makeConstraints { maker in
            maker.top.equalTo(coinPricesButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        coinHistoricalPriceButton.setTitle("Historical Price", for: .normal)
        coinHistoricalPriceButton.setTitleColor(.systemBlue, for: .normal)
        coinHistoricalPriceButton.addTarget(self, action: #selector(onTapCoinHistoricalPrice), for: .touchUpInside)

        let globalMarketInfoButton = UIButton()

        view.addSubview(globalMarketInfoButton)
        globalMarketInfoButton.snp.makeConstraints { maker in
            maker.top.equalTo(coinHistoricalPriceButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        globalMarketInfoButton.setTitle("Global Market Info", for: .normal)
        globalMarketInfoButton.setTitleColor(.systemBlue, for: .normal)
        globalMarketInfoButton.addTarget(self, action: #selector(onTapGlobalMarketInfo), for: .touchUpInside)
    }

    @objc private func onTapCoinPrices() {
        Singleton.instance.kit.coinPriceMapObservable(coinUids: ["bitcoin", "ethereum"], currencyCode: "USD")
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] coinPriceMap in
                    print("ON NEXT: \(coinPriceMap)")
                })
                .disposed(by: disposeBag)
    }

    @objc private func onTapCoinHistoricalPrice() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2020, month: 3, day: 15)
        guard let date = calendar.date(from: components) else {
            return
        }

        Singleton.instance.kit.coinHistoricalPriceValueSingle(coinUid: "bitcoin", currencyCode: "USD", timestamp: date.timeIntervalSince1970)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] value in
                    print("Historical Price: \(value)")
                })
                .disposed(by: disposeBag)
    }

    @objc private func onTapGlobalMarketInfo() {
        Singleton.instance.kit.globalMarketPointsSingle(currencyCode: "USD", timePeriod: .hour24)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] points in
                    print("SUCCESS: count: \(points.count)\n\(points.map { "\($0)" }.joined(separator: "\n"))")
                })
                .disposed(by: disposeBag)
    }

}
