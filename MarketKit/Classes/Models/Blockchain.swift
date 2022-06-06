public struct Blockchain {
    public let type: BlockchainType
    public let name: String

    public init(type: BlockchainType, name: String) {
        self.type = type
        self.name = name
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
        lhs.type == rhs.type && lhs.name == rhs.name
    }

}

extension Blockchain: CustomStringConvertible {

    public var description: String {
        "Blockchain [type: \(type); name: \(name)]"
    }

}
