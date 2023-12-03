import Combine
import Foundation
import HsExtensions
import HsToolKit

protocol ISchedulerProvider {
    var id: String { get }
    var lastSyncTimestamp: TimeInterval? { get }
    var expirationInterval: TimeInterval { get }
    func sync() async throws
    func notifyExpired()
}

class Scheduler {
    private static let retryInterval: TimeInterval = 5

    private let bufferInterval: TimeInterval

    private let provider: ISchedulerProvider
    private let reachabilityManager: ReachabilityManager
    private var logger: Logger?

    private var cancellables = Set<AnyCancellable>()
    private var tasks = Set<AnyTask>()
    private var scheduledTask: Task<Void, Error>?

    private var syncInProgress = false
    private var expirationNotified = false

    private let queue = DispatchQueue(label: "io.horizontalsystems.market_kit.scheduler", qos: .utility)

    init(provider: ISchedulerProvider, reachabilityManager: ReachabilityManager, bufferInterval: TimeInterval = 5, logger: Logger? = nil) {
        self.provider = provider
        self.reachabilityManager = reachabilityManager
        self.bufferInterval = bufferInterval
        self.logger = logger

        reachabilityManager.$isReachable
            .sink { [weak self] reachable in
                if reachable {
                    self?.autoSchedule()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        logger?.debug("Deinit Scheduler: \(provider.id)")
    }

    private func sync() {
        queue.async {
            self._sync()
        }
    }

    private func _sync() {
        // check if sync process is already running
        guard !syncInProgress else {
            logger?.debug("Scheduler \(provider.id): Sync already running")
            return
        }

        logger?.debug("Scheduler \(provider.id): Sync started")

        syncInProgress = true

        Task { [weak self, provider] in
            do {
                try await provider.sync()
                self?.onSyncSuccess()
            } catch {
                self?.onSyncError(error: error)
            }
        }.store(in: &tasks)
    }

    private func onSyncSuccess() {
        queue.async {
            self.logger?.debug("Scheduler \(self.provider.id): Sync success")

            self.expirationNotified = false

            self.syncInProgress = false
            self.autoSchedule(minDelay: Self.retryInterval)
        }
    }

    private func onSyncError(error: Error) {
        queue.async {
            self.logger?.error("Scheduler \(self.provider.id): Sync error: \(error)")

            self._notifyExpiration()

            self.syncInProgress = false
            self._schedule(delay: Self.retryInterval)
        }
    }

    private func _schedule(delay: TimeInterval) {
        let intDelay = Int(delay.rounded(.up))

        logger?.debug("Scheduler \(provider.id): schedule delay: \(intDelay) sec")

        // invalidate previous timer if exists
        scheduledTask?.cancel()

        // schedule new timer
        scheduledTask = Task<Void, Error> { [weak self] in
            try await Task.sleep(nanoseconds: UInt64(intDelay) * 1_000_000_000)
            self?.sync()
        }

        scheduledTask?.store(in: &tasks)
    }

    private func _notifyExpiration() {
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

        queue.async {
            self._schedule(delay: max(minDelay, delay))
        }
    }
}

extension Scheduler {
    func forceSchedule() {
        logger?.debug("Scheduler \(provider.id): Force schedule")

        queue.async {
            self._schedule(delay: 0)
        }
    }
}
