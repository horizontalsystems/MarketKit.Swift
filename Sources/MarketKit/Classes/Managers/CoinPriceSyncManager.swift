import Combine
import Foundation

struct CoinPriceKey: Hashable {
    let tag: String
    let coinUids: [String]
    let currencyCode: String

    var ids: [String] {
        coinUids.sorted()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
        hasher.combine(currencyCode)
        ids.forEach {
            hasher.combine($0)
        }
    }

    static func == (lhs: CoinPriceKey, rhs: CoinPriceKey) -> Bool {
        lhs.tag == rhs.tag && lhs.ids == rhs.ids && lhs.currencyCode == rhs.currencyCode
    }
}

class CoinPriceSyncManager {
    private let queue = DispatchQueue(label: "io.horizontalsystems.market_kit.coin_price_sync_manager", qos: .userInitiated)

    private let schedulerFactory: CoinPriceSchedulerFactory
    private var schedulers = [String: Scheduler]()
    private var subjects = [CoinPriceKey: CountedPassthroughSubject<[String: CoinPrice], Never>]()

    init(schedulerFactory: CoinPriceSchedulerFactory) {
        self.schedulerFactory = schedulerFactory
    }

    private func _cleanUp(key: CoinPriceKey) {
        if let subject = subjects[key], subject.subscribersCount > 0 {
            return
        }
        subjects[key] = nil

        if subjects.filter({ subjectKey, _ in subjectKey.currencyCode == key.currencyCode }).isEmpty {
            schedulers[key.currencyCode] = nil
        }
    }

    private func onDisposed(key: CoinPriceKey) {
        queue.async {
            self._cleanUp(key: key)
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

    private func observingCoinUids(tag: String, currencyCode: String) -> Set<String> {
        var coinUids = Set<String>()

        subjects.forEach { existingKey, _ in
            if existingKey.tag == tag, existingKey.currencyCode == currencyCode {
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
        // get set of all listening coins
        // found tokens which needed to update
        // make new key for force update

        let newCoinTypes = Set(key.coinUids).subtracting(observingCoinUids(currencyCode: key.currencyCode))
        return !newCoinTypes.isEmpty
    }

    private func _subject(key: CoinPriceKey) -> AnyPublisher<[String: CoinPrice], Never> {
        let subject: CountedPassthroughSubject<[String: CoinPrice], Never>
        var forceUpdate = false

        if let candidate = subjects[key] {
            subject = candidate
        } else { // create new subject
            forceUpdate = needForceUpdate(key: key) // if subject has non-subscribed tokens we need force schedule

            subject = CountedPassthroughSubject<[String: CoinPrice], Never>()
            subjects[key] = subject
        }

        if schedulers[key.currencyCode] == nil { // create scheduler if not exist
            let scheduler = schedulerFactory.scheduler(currencyCode: key.currencyCode, coinUidDataSource: self)
            schedulers[key.currencyCode] = scheduler
        }

        if forceUpdate { // make request for scheduler immediately
            schedulers[key.currencyCode]?.forceSchedule()
        }

        return subject
            .handleEvents(
                receiveCompletion: { [weak self] _ in self?.onDisposed(key: key) },
                receiveCancel: { [weak self] in self?.onDisposed(key: key) }
            )
            .eraseToAnyPublisher()
    }
}

extension CoinPriceSyncManager: ICoinPriceCoinUidDataSource {
    func allCoinUids(currencyCode: String) -> [String] {
        queue.sync {
            Array(observingCoinUids(currencyCode: currencyCode))
        }
    }

    func combinedCoinUids(currencyCode: String) -> ([String], [String]) {
        queue.sync {
            let allCoinUids = Array(observingCoinUids(currencyCode: currencyCode))
            let walletCoinUids = Array(observingCoinUids(tag: "wallet", currencyCode: currencyCode))
            return (allCoinUids, walletCoinUids)
        }
    }
}

extension CoinPriceSyncManager {
    func refresh(currencyCode: String) {
        queue.async {
            self.schedulers[currencyCode]?.forceSchedule()
        }
    }

    func coinPricePublisher(tag: String, coinUid: String, currencyCode: String) -> AnyPublisher<CoinPrice, Never> {
        queue.sync {
            let coinPriceKey = CoinPriceKey(tag: tag, coinUids: [coinUid], currencyCode: currencyCode)

            return _subject(key: coinPriceKey)
                .flatMap { dictionary in
                    if let coinPrice = dictionary[coinUid] {
                        return Just(coinPrice).eraseToAnyPublisher()
                    }
                    return Empty().eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }

    func coinPriceMapPublisher(tag: String, coinUids: [String], currencyCode: String) -> AnyPublisher<[String: CoinPrice], Never> {
        let key = CoinPriceKey(tag: tag, coinUids: coinUids, currencyCode: currencyCode)

        return queue.sync {
            _subject(key: key).eraseToAnyPublisher()
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
                        subject.send(coinPrices)
                    }
                }
            }
        }
    }
}

class CountedPassthroughSubject<Output, Failure>: Subject where Failure: Error {
    private(set) var subscribersCount = 0
    private let subject = PassthroughSubject<Output, Failure>()

    func send(_ value: Output) {
        subject.send(value)
    }

    func send(completion: Subscribers.Completion<Failure>) {
        subject.send(completion: completion)
    }

    func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }

    func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
        subject
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.subscribersCount += 1 },
                receiveCompletion: { [weak self] _ in self?.subscribersCount -= 1 },
                receiveCancel: { [weak self] in self?.subscribersCount -= 1 }
            )
            .receive(subscriber: subscriber)
    }
}
