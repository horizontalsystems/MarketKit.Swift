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

        let globalMarketInfoButton = UIButton()

        view.addSubview(globalMarketInfoButton)
        globalMarketInfoButton.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            maker.centerX.equalToSuperview()
        }

        globalMarketInfoButton.setTitle("Global Market Info", for: .normal)
        globalMarketInfoButton.setTitleColor(.systemBlue, for: .normal)
        globalMarketInfoButton.addTarget(self, action: #selector(onTapGlobalMarketInfo), for: .touchUpInside)
    }

    @objc private func onTapGlobalMarketInfo() {
        Singleton.instance.kit.globalMarketInfoSingle(currencyCode: "USD", timePeriod: .hour24)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] info in
                    print("SUCCESS: count: \(info.points.count)\n\(info.points.map { "\($0)" }.joined(separator: "\n"))")
                })
                .disposed(by: disposeBag)
    }

}
