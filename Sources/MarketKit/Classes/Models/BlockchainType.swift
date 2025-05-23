public enum BlockchainType {
    case bitcoin
    case bitcoinCash
    case ecash
    case litecoin
    case dash
    case zcash
    case ethereum
    case binanceSmartChain
    case polygon
    case avalanche
    case optimism
    case arbitrumOne
    case gnosis
    case fantom
    case tron
    case solana
    case ton
    case base
    case zkSync
    case stellar
    case unsupported(uid: String)

    public init(uid: String) {
        switch uid {
        case "bitcoin": self = .bitcoin
        case "bitcoin-cash": self = .bitcoinCash
        case "ecash": self = .ecash
        case "litecoin": self = .litecoin
        case "dash": self = .dash
        case "zcash": self = .zcash
        case "ethereum": self = .ethereum
        case "binance-smart-chain": self = .binanceSmartChain
        case "polygon-pos": self = .polygon
        case "avalanche": self = .avalanche
        case "optimistic-ethereum": self = .optimism
        case "arbitrum-one": self = .arbitrumOne
        case "gnosis": self = .gnosis
        case "fantom": self = .fantom
        case "tron": self = .tron
        case "solana": self = .solana
        case "the-open-network": self = .ton
        case "base": self = .base
        case "zksync": self = .zkSync
        case "stellar": self = .stellar
        default: self = .unsupported(uid: uid)
        }
    }

    public var uid: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .bitcoinCash: return "bitcoin-cash"
        case .ecash: return "ecash"
        case .litecoin: return "litecoin"
        case .dash: return "dash"
        case .zcash: return "zcash"
        case .ethereum: return "ethereum"
        case .binanceSmartChain: return "binance-smart-chain"
        case .polygon: return "polygon-pos"
        case .avalanche: return "avalanche"
        case .optimism: return "optimistic-ethereum"
        case .arbitrumOne: return "arbitrum-one"
        case .gnosis: return "gnosis"
        case .fantom: return "fantom"
        case .tron: return "tron"
        case .solana: return "solana"
        case .ton: return "the-open-network"
        case .base: return "base"
        case .zkSync: return "zksync"
        case .stellar: return "stellar"
        case let .unsupported(uid): return uid
        }
    }
}

extension BlockchainType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

extension BlockchainType: Equatable {
    public static func == (lhs: BlockchainType, rhs: BlockchainType) -> Bool {
        lhs.uid == rhs.uid
    }
}
