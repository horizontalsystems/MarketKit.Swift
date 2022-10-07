import Foundation
import RxSwift
import HsToolKit

protocol ISchedulerProvider {
    var id: String { get }
    var lastSyncTimestamp: TimeInterval? { get }
    var expirationInterval: TimeInterval { get }
    var syncSingle: Single<Void> { get }
    func notifyExpired()
}

class Scheduler {
    private static let retryInterval: TimeInterval = 30

    private let bufferInterval: TimeInterval

    private let provider: ISchedulerProvider
    private let reachabilityManager: IReachabilityManager
    private var logger: Logger?

    private let disposeBag = DisposeBag()
    private var timerDisposable: Disposable?

    private var syncInProgress = false
    private var expirationNotified = false

    init(provider: ISchedulerProvider, reachabilityManager: IReachabilityManager, bufferInterval: TimeInterval = 5, logger: Logger? = nil) {
        self.provider = provider
        self.reachabilityManager = reachabilityManager
        self.bufferInterval = bufferInterval
        self.logger = logger

        reachabilityManager.reachabilityObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onNext: { [weak self] reachable in
                    if reachable {
                        print("reachable")
                        self?.autoSchedule()
                    }
                })
                .disposed(by: disposeBag)
    }

    deinit {
        logger?.debug("Deinit Scheduler: \(provider.id)")
    }

    private func sync() {
        notifyExpiration()

        // check if sync process is already running
        guard !syncInProgress else {
            logger?.debug("Scheduler \(provider.id): Sync already running")
            return
        }

        logger?.debug("Scheduler \(provider.id): Sync started")

        syncInProgress = true

        provider.syncSingle
                .subscribe(onSuccess: { [weak self] in
                    self?.onSyncSuccess()
                }, onError: { [weak self] error in
                    self?.onSyncError(error: error)
                })
                .disposed(by: disposeBag)
    }

    private func onSyncSuccess() {
        logger?.debug("Scheduler \(provider.id): Sync success")

        expirationNotified = false

        syncInProgress = false
        autoSchedule(minDelay: Self.retryInterval)
    }

    private func onSyncError(error: Error) {
        logger?.error("Scheduler \(provider.id): Sync error: \(error)")

        syncInProgress = false
        schedule(delay: Self.retryInterval)
    }

    private func schedule(delay: TimeInterval) {
        let intDelay = Int(delay.rounded(.up))

        logger?.debug("Scheduler \(provider.id): schedule delay: \(intDelay) sec")

        // invalidate previous timer if exists
        timerDisposable?.dispose()

        // schedule new timer
        timerDisposable = Observable<Int>
                .timer(.seconds(intDelay), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(onNext: { [weak self] _ in
                    self?.sync()
                })

        timerDisposable?.disposed(by: disposeBag)
    }

    private func notifyExpiration() {
        guard !expirationNotified else {
            return
        }

        let currentTimestamp = Date().timeIntervalSince1970
        if let lastSyncTimestamp = provider.lastSyncTimestamp, currentTimestamp - lastSyncTimestamp < provider.expirationInterval {
            return
        }

        logger?.debug("Scheduler \(provider.id): Notifying expiration")

        provider.notifyExpired()
        expirationNotified = true
    }

    private func autoSchedule(minDelay: TimeInterval = 0) {
        var delay: TimeInterval = 0

        if let lastSyncTimestamp = provider.lastSyncTimestamp {
            let currentTimestamp = Date().timeIntervalSince1970
            let diff = currentTimestamp - lastSyncTimestamp
            delay = max(0, provider.expirationInterval - bufferInterval - diff)
        }

        schedule(delay: max(minDelay, delay))
    }

}

extension Scheduler {

    func schedule() {
        logger?.debug("Scheduler \(provider.id): Auto schedule")

        DispatchQueue.global(qos: .utility).async {
            self.autoSchedule()
        }
    }

    func forceSchedule() {
        logger?.debug("Scheduler \(provider.id): Force schedule")

        DispatchQueue.global(qos: .userInitiated).async {
            self.schedule(delay: 0)
        }
    }

}
