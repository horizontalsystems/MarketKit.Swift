public enum PlatformType {
    case ethereum
    case binanceSmartChain
    case polygon
    case optimism
    case arbitrumOne

    public var baseCoinType: CoinType {
        switch self {
        case .ethereum: return .ethereum
        case .binanceSmartChain: return .binanceSmartChain
        case .polygon: return .polygon
        case .optimism: return .ethereumOptimism
        case .arbitrumOne: return .ethereumArbitrumOne
        }
    }

    public var evmCoinTypeIdPrefix: String {
        switch self {
        case .ethereum: return "erc20"
        case .binanceSmartChain: return "bep20"
        case .polygon: return "mrc20"
        case .optimism: return "optimismErc20"
        case .arbitrumOne: return "arbitrumOneErc20"
        }
    }

}
