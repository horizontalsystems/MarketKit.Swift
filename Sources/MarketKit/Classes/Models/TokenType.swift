public enum TokenType {
    public enum Derivation: String, CaseIterable {
        case bip44
        case bip49
        case bip84
        case bip86
    }

    public enum AddressType: String, CaseIterable {
        case type0
        case type145
    }

    case native
    case derived(derivation: Derivation)
    case addressType(type: AddressType)
    case eip20(address: String)
    case spl(address: String)
    case jetton(address: String)
    case stellar(code: String, issuer: String)
    case unsupported(type: String, reference: String?)

    public init(type: String, reference: String? = nil) {
        let chunks = type.split(separator: ":").map { String($0) }

        if chunks.count == 1 {
            switch chunks[0] {
            case "native":
                self = .native
                return
            case "eip20":
                if let reference {
                    self = .eip20(address: reference)
                    return
                }
            case "spl":
                if let reference {
                    self = .spl(address: reference)
                    return
                }
            case "the-open-network":
                if let reference {
                    self = .jetton(address: reference)
                    return
                }
            case "stellar":
                if let reference {
                    let components = reference.components(separatedBy: "-")
                    if components.count == 2 {
                        self = .stellar(code: components[0], issuer: components[1])
                        return
                    }
                }
            default: ()
            }
        } else if chunks.count == 2 {
            switch chunks[0] {
            case "derived":
                if let derivation = Derivation(rawValue: chunks[1]) {
                    self = .derived(derivation: derivation)
                    return
                }
            case "address_type":
                if let addressType = AddressType(rawValue: chunks[1]) {
                    self = .addressType(type: addressType)
                    return
                }
            default: ()
            }
        }

        self = .unsupported(type: type, reference: reference)
    }

    public init?(id: String) {
        let chunks = id.split(separator: ":").map { String($0) }

        switch chunks.count {
        case 1:
            switch chunks[0] {
            case "native": self = .native
            default: return nil
            }
        case 2:
            switch chunks[0] {
            case "derived":
                guard let derivation = Derivation(rawValue: chunks[1]) else {
                    return nil
                }
                self = .derived(derivation: derivation)
            case "address_type":
                guard let type = AddressType(rawValue: chunks[1]) else {
                    return nil
                }
                self = .addressType(type: type)
            case "eip20": self = .eip20(address: chunks[1])
            case "spl": self = .spl(address: chunks[1])
            case "the-open-network": self = .jetton(address: chunks[1])
            case "stellar":
                let components = chunks[1].components(separatedBy: "-")
                if components.count == 2 {
                    self = .stellar(code: components[0], issuer: components[1])
                } else {
                    return nil
                }
            case "unsupported": self = .unsupported(type: chunks[1], reference: nil)
            default: return nil
            }
        case 3:
            switch chunks[0] {
            case "unsupported": self = .unsupported(type: chunks[1], reference: chunks[2])
            default: return nil
            }
        default:
            return nil
        }
    }

    public var id: String {
        switch self {
        case .native:
            return "native"
        case let .derived(derivation):
            return ["derived", derivation.rawValue].joined(separator: ":")
        case let .addressType(type):
            return ["address_type", type.rawValue].joined(separator: ":")
        case let .eip20(address):
            return ["eip20", address].joined(separator: ":")
        case let .spl(address):
            return ["spl", address].joined(separator: ":")
        case let .jetton(address):
            return ["the-open-network", address].joined(separator: ":")
        case let .stellar(code, issuer):
            return ["stellar", [code, issuer].joined(separator: "-")].joined(separator: ":")
        case let .unsupported(type, reference):
            if let reference {
                return ["unsupported", type, reference].joined(separator: ":")
            } else {
                return ["unsupported", type].joined(separator: ":")
            }
        }
    }

    public var values: (type: String, reference: String?) {
        switch self {
        case .native: return (type: "native", reference: nil)
        case let .derived(derivation): return (type: "derived:\(derivation.rawValue)", reference: nil)
        case let .addressType(type): return (type: "address_type:\(type.rawValue)", reference: nil)
        case let .eip20(address): return (type: "eip20", reference: address)
        case let .spl(address): return (type: "spl", reference: address)
        case let .jetton(address): return (type: "the-open-network", reference: address)
        case let .stellar(code, issuer): return (type: "stellar", reference: [code, issuer].joined(separator: "-"))
        case let .unsupported(type, reference): return (type: type, reference: reference)
        }
    }
}

extension TokenType: Equatable {
    public static func == (lhs: TokenType, rhs: TokenType) -> Bool {
        let (lhsType, lhsReference) = lhs.values
        let (rhsType, rhsReference) = rhs.values

        return lhsType == rhsType && lhsReference == rhsReference
    }
}

extension TokenType: Hashable {
    public func hash(into hasher: inout Hasher) {
        let (type, reference) = values

        hasher.combine(type)
        hasher.combine(reference)
    }
}
