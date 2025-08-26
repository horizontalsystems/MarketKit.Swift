import Foundation

public struct TopPlatform {
    public let blockchain: Blockchain
    public let rank: Int?
    public let protocolsCount: Int?
    public let marketCap: Decimal?

    public let ranks: [HsTimePeriod: Int]
    public let changes: [HsTimePeriod: Decimal]
}

extension TopPlatform: Hashable {
    public static func == (lhs: TopPlatform, rhs: TopPlatform) -> Bool {
        lhs.blockchain.uid == rhs.blockchain.uid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(blockchain.uid)
    }
}

extension TopPlatform: Identifiable {
    public var id: String {
        blockchain.uid
    }
}
