public struct Blockchain {
    public let type: BlockchainType
    public let name: String
    public let explorerUrl: String?

    public init(type: BlockchainType, name: String, explorerUrl: String?) {
        self.type = type
        self.name = name
        self.explorerUrl = explorerUrl
    }

    public var uid: String {
        type.uid
    }

}

extension Blockchain: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

}

extension Blockchain: Equatable {

    public static func ==(lhs: Blockchain, rhs: Blockchain) -> Bool {
        lhs.type == rhs.type && lhs.name == rhs.name && lhs.explorerUrl == rhs.explorerUrl
    }

}

extension Blockchain: CustomStringConvertible {

    public var description: String {
        "Blockchain [type: \(type); name: \(name); explorerUrl: \(explorerUrl ?? "nil")]"
    }

}
