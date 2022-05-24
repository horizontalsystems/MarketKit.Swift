import Foundation

public struct NftEvent {
    public let asset: NftAsset
    public let type: EventType?
    public let date: Date
    public let amount: NftPrice?
}

extension NftEvent {

    public enum EventType: String {
        case list = "list"
        case sale = "sale"
        case offer = "offer"
        case bid = "bid"
        case bidCancel = "bid_cancel"
        case transfer = "transfer"
        case approve = "approve"
        case custom = "custom"
        case payout = "payout"
        case cancel = "cancel"
        case bulkCancel = "bulk_cancel"
    }

}

public struct PagedNftEvents {
    public let events: [NftEvent]
    public let cursor: String?
}
