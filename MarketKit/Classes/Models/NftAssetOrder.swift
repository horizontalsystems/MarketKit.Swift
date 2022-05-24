import Foundation

public struct NftAssetOrder {
    public let closingDate: Date
    public let price: NftPrice?
    public let emptyTaker: Bool
    public let side: Int
    public let v: Int?
    public let ethValue: Decimal
}
