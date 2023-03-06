public struct Blockchain {
    public let type: BlockchainType
    public let name: String
    public let eip3091url: String?

    public init(type: BlockchainType, name: String, eip3091url: String?) {
        self.type = type
        self.name = name
        self.eip3091url = eip3091url
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
        lhs.type == rhs.type
    }

}

extension Blockchain: CustomStringConvertible {

    public var description: String {
        "Blockchain [type: \(type); name: \(name); eip3091url: \(eip3091url ?? "nil")]"
    }

}
