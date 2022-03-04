public enum PlatformType {
    case ethereum
    case binanceSmartChain
    case polygon
    case optimism
    case arbitrumOne

    public var coinTypeIdPrefixes: [String] {
        switch self {
        case .ethereum: return ["ethereum", "erc20"]
        case .binanceSmartChain: return ["binanceSmartChain", "bep20"]
        case .polygon: return ["polygon", "mrc20"]
        case .optimism: return ["ethereumOptimism", "optimismErc20"]
        case .arbitrumOne: return ["ethereumArbitrumOne", "arbitrumOneErc20"]
        }
    }
}
