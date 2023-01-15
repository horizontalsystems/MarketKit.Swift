public enum BlockchainType {
    case bitcoin
    case bitcoinCash
    case litecoin
    case dash
    case zcash
    case ethereum
    case binanceSmartChain
    case binanceChain
    case polygon
    case avalanche
    case optimism
    case arbitrumOne
    case gnosis
    case solana
    case ethereumGoerli
    case unsupported(uid: String)

    public init(uid: String) {
        switch uid {
        case "bitcoin": self = .bitcoin
        case "bitcoin-cash": self = .bitcoinCash
        case "litecoin": self = .litecoin
        case "dash": self = .dash
        case "zcash": self = .zcash
        case "ethereum": self = .ethereum
        case "binance-smart-chain": self = .binanceSmartChain
        case "binancecoin": self = .binanceChain
        case "polygon-pos": self = .polygon
        case "avalanche": self = .avalanche
        case "optimistic-ethereum": self = .optimism
        case "arbitrum-one": self = .arbitrumOne
        case "gnosis": self = .gnosis
        case "solana": self = .solana
        case "ethereum-goerli": self = .ethereumGoerli
        default: self = .unsupported(uid: uid)
        }
    }

    public var uid: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .bitcoinCash: return "bitcoin-cash"
        case .litecoin: return "litecoin"
        case .dash: return "dash"
        case .zcash: return "zcash"
        case .ethereum: return "ethereum"
        case .binanceSmartChain: return "binance-smart-chain"
        case .binanceChain: return "binancecoin"
        case .polygon: return "polygon-pos"
        case .avalanche: return "avalanche"
        case .optimism: return "optimistic-ethereum"
        case .arbitrumOne: return "arbitrum-one"
        case .gnosis: return "gnosis"
        case .solana: return "solana"
        case .ethereumGoerli: return "ethereum-goerli"
        case .unsupported(let uid): return uid
        }
    }
}

extension BlockchainType: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }

}

extension BlockchainType: Equatable {

    public static func ==(lhs: BlockchainType, rhs: BlockchainType) -> Bool {
        lhs.uid == rhs.uid
    }

}
