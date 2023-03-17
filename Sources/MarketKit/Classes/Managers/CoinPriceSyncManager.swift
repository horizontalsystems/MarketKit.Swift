import Foundation
import RxSwift

struct CoinPriceKey: Hashable {
    let coinUids: [String]
    let currencyCode: String

    var ids: [String] {
        coinUids.sorted()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(currencyCode)
        ids.forEach {
            hasher.combine($0)
        }
    }

    static func ==(lhs: CoinPriceKey, rhs: CoinPriceKey) -> Bool {
        lhs.ids == rhs.ids && lhs.currencyCode == rhs.currencyCode
    }

}

class CoinPriceSyncManager {
    private let queue = DispatchQueue(label: "io.horizontalsystems.market_kit.coin_price_sync_manager", qos: .userInitiated)

    private let schedulerFactory: CoinPriceSchedulerFactory
    private var schedulers = [String: Scheduler]()
    private var subjects = [CoinPriceKey: PublishSubject<[String: CoinPrice]>]()

    init(schedulerFactory: CoinPriceSchedulerFactory) {
        self.schedulerFactory = schedulerFactory
    }

    private func cleanUp(key: CoinPriceKey) {
        if let subject = subjects[key], subject.hasObservers {
            return
        }
        subjects[key] = nil

        if subjects.filter({ (subjectKey, _) in subjectKey.currencyCode == key.currencyCode }).isEmpty {
            schedulers[key.currencyCode] = nil
        }
    }

    private func onDisposed(key: CoinPriceKey) {
        queue.async {
            self.cleanUp(key: key)
        }
    }

    private func observingCoinUids(currencyCode: String) -> Set<String> {
        var coinUids = Set<String>()

        subjects.forEach { existingKey, _ in
            if existingKey.currencyCode == currencyCode {
                coinUids.formUnion(Set(existingKey.coinUids))
            }
        }

        return coinUids
    }

    private var observingCurrencies: Set<String> {
        var currencyCodes = Set<String>()
        subjects.forEach { existKey, _ in
            currencyCodes.insert(existKey.currencyCode)
        }
        return currencyCodes
    }

    private func needForceUpdate(key: CoinPriceKey) -> Bool {
        //get set of all listening coins
        //found tokens which needed to update
        //make new key for force update

        let newCoinTypes = Set(key.coinUids).subtracting(observingCoinUids(currencyCode: key.currencyCode))
        return !newCoinTypes.isEmpty
    }

    private func subject(key: CoinPriceKey) -> Observable<[String: CoinPrice]> {
        let subject: PublishSubject<[String: CoinPrice]>
        var forceUpdate: Bool = false

        if let candidate = subjects[key] {
            subject = candidate
        } else {                                        // create new subject
            forceUpdate = needForceUpdate(key: key)     // if subject has non-subscribed tokens we need force schedule

            subject = PublishSubject<[String: CoinPrice]>()
            subjects[key] = subject
        }

        if schedulers[key.currencyCode] == nil {        // create scheduler if not exist
            let scheduler = schedulerFactory.scheduler(currencyCode: key.currencyCode, coinUidDataSource: self)
            schedulers[key.currencyCode] = scheduler
        }

        if forceUpdate {                                // make request for scheduler immediately
            schedulers[key.currencyCode]?.forceSchedule()
        }

        return subject
                .do(onDispose: { [weak self] in
                    self?.onDisposed(key: key)
                })
    }

}

extension CoinPriceSyncManager: ICoinPriceCoinUidDataSource {

    func coinUids(currencyCode: String) -> [String] {
        queue.sync {
            Array(observingCoinUids(currencyCode: currencyCode))
        }
    }

}

extension CoinPriceSyncManager {

    func refresh(currencyCode: String) {
        queue.async {
            self.schedulers[currencyCode]?.forceSchedule()
        }
    }

    func coinPriceObservable(coinUid: String, currencyCode: String) -> Observable<CoinPrice> {
        queue.sync {
            let coinPriceKey = CoinPriceKey(coinUids: [coinUid], currencyCode: currencyCode)

            return subject(key: coinPriceKey)
                    .flatMap { dictionary -> Observable<CoinPrice> in
                        if let coinPrice = dictionary[coinUid] {
                            return Observable.just(coinPrice)
                        }
                        return Observable.never()
                    }
        }
    }

    func coinPriceMapObservable(coinUids: [String], currencyCode: String) -> Observable<[String: CoinPrice]> {
        let key = CoinPriceKey(coinUids: coinUids, currencyCode: currencyCode)

        return queue.sync {
            subject(key: key).asObservable()
        }
    }

}

extension CoinPriceSyncManager: ICoinPriceManagerDelegate {

    func didUpdate(coinPriceMap: [String: CoinPrice], currencyCode: String) {
        queue.async {
            self.subjects.forEach { key, subject in
                // send new rates for all subject which has at least one coinType in key
                if key.currencyCode == currencyCode {
                    let coinPrices = coinPriceMap.filter { coinUid, _ in
                        key.coinUids.contains(coinUid)
                    }

                    if !coinPrices.isEmpty {
                        subject.onNext(coinPrices)
                    }
                }
            }
        }
    }

}
