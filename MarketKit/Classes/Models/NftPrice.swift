import Foundation

public struct NftPrice {
    public let platformCoin: PlatformCoin
    public let value: Decimal

    public init(platformCoin: PlatformCoin, value: Decimal) {
        self.platformCoin = platformCoin
        self.value = value
    }

}
