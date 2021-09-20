public enum CoinType: Decodable {
    case bitcoin
    case bitcoinCash
    case litecoin
    case dash
    case zcash
    case ethereum
    case binanceSmartChain
    case erc20(address: String)
    case bep20(address: String)
    case bep2(symbol: String)
    case sol20(address: String)
    case unsupported(type: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        self.init(id: value)
    }

    init?(type: String, address: String?, symbol: String?) {
        switch type {
        case "bitcoin":
            self = .bitcoin
        case "bitcoin-cash":
            self = .bitcoinCash
        case "litecoin":
            self = .litecoin
        case "dash":
            self = .dash
        case "zcash":
            self = .zcash
        case "ethereum":
            self = .ethereum
        case "binance-smart-chain":
            self = .binanceSmartChain
        case "erc20":
            if let address = address {
                self = .erc20(address: address)
            } else {
                return nil
            }
        case "bep20":
            if let address = address {
                self = .bep20(address: address)
            } else {
                return nil
            }
        case "bep2":
            if let symbol = symbol {
                self = .bep2(symbol: symbol)
            } else {
                return nil
            }
        case "sol20":
            if let address = address {
                self = .sol20(address: address)
            } else {
                return nil
            }
        default:
            self = .unsupported(type: type)
        }
    }

}

extension CoinType: Equatable {

    public static func ==(lhs: CoinType, rhs: CoinType) -> Bool {
        switch (lhs, rhs) {
        case (.bitcoin, .bitcoin): return true
        case (.bitcoinCash, .bitcoinCash): return true
        case (.litecoin, .litecoin): return true
        case (.dash, .dash): return true
        case (.zcash, .zcash): return true
        case (.ethereum, .ethereum): return true
        case (.binanceSmartChain, .binanceSmartChain): return true
        case (.erc20(let lhsAddress), .erc20(let rhsAddress)):
            return lhsAddress.lowercased() == rhsAddress.lowercased()
        case (.bep20(let lhsAddress), .bep20(let rhsAddress)):
            return lhsAddress.lowercased() == rhsAddress.lowercased()
        case (.bep2(let lhsSymbol), .bep2(let rhsSymbol)):
            return lhsSymbol == rhsSymbol
        case (.sol20(let lhsAddress), .sol20(let rhsAddress)):
            return lhsAddress.lowercased() == rhsAddress.lowercased()
        case (.unsupported(let lhsType), .unsupported(let rhsType)):
            return lhsType == rhsType
        default: return false
        }
    }

}

extension CoinType: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension CoinType: Identifiable {
    public typealias ID = String

    public init(id: ID) {
        let chunks = id.split(separator: "|")

        if chunks.count == 1 {
            switch chunks[0] {
            case "bitcoin": self = .bitcoin
            case "bitcoinCash": self = .bitcoinCash
            case "litecoin": self = .litecoin
            case "dash": self = .dash
            case "zcash": self = .zcash
            case "ethereum": self = .ethereum
            case "binanceSmartChain": self = .binanceSmartChain
            default: self = .unsupported(type: String(chunks[0]))
            }
        } else {
            switch chunks[0] {
            case "erc20": self = .erc20(address: String(chunks[1]))
            case "bep20": self = .bep20(address: String(chunks[1]))
            case "bep2": self = .bep2(symbol: String(chunks[1]))
            case "sol20": self = .sol20(address: String(chunks[1]))
            case "unsupported": self = .unsupported(type: chunks.suffix(from: 1).joined(separator: "|"))
            default: self = .unsupported(type: chunks.joined(separator: "|"))
            }
        }
    }

    public var id: ID {
        switch self {
        case .bitcoin: return "bitcoin"
        case .bitcoinCash: return "bitcoinCash"
        case .litecoin: return "litecoin"
        case .dash: return "dash"
        case .zcash: return "zcash"
        case .ethereum: return "ethereum"
        case .binanceSmartChain: return "binanceSmartChain"
        case .erc20(let address): return ["erc20", address].joined(separator: "|")
        case .bep20(let address): return ["bep20", address].joined(separator: "|")
        case .bep2(let symbol): return ["bep2", symbol].joined(separator: "|")
        case .sol20(let address): return ["sol20", address].joined(separator: "|")
        case .unsupported(let type): return ["unsupported", type].joined(separator: "|")
        }
    }

}

extension CoinType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .bitcoinCash: return "bitcoinCash"
        case .litecoin: return "litecoin"
        case .dash: return "dash"
        case .zcash: return "zcash"
        case .ethereum: return "ethereum"
        case .binanceSmartChain: return "binanceSmartChain"
        case .erc20(let address): return ["erc20", "\(address.prefix(4))...\(address.suffix(2))"].joined(separator: "|")
        case .bep20(let address): return ["bep20", "\(address.prefix(4))...\(address.suffix(2))"].joined(separator: "|")
        case .bep2(let symbol): return ["bep2", symbol].joined(separator: "|")
        case .sol20(let address): return ["sol20", "\(address.prefix(4))...\(address.suffix(2))"].joined(separator: "|")
        case .unsupported(let type): return ["unsupported", type].joined(separator: "|")
        }
    }

}
