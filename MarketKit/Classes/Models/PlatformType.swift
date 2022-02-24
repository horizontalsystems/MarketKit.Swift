public enum PlatformType {
    case ethereum
    case binanceSmartChain
    case polygonPos

    public var coinTypeIdPrefixes: [String] {
        switch self {
        case .ethereum: return ["ethereum", "erc20"]
        case .binanceSmartChain: return ["binanceSmartChain", "bep20"]
        case .polygonPos: return ["polygonPos"]
        }
    }
}
