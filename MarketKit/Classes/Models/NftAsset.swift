import ObjectMapper

public struct NftAsset {
    public let contract: NftCollection.Contract
    public let collectionUid: String
    public let tokenId: String
    public let name: String?
    public let imageUrl: String?
    public let imagePreviewUrl: String?
    public let description: String?
    public let externalLink: String?
    public let permalink: String?
    public let traits: [Trait]
    public let lastSalePrice: NftPrice?
    public let onSale: Bool
    public let orders: [NftAssetOrder]

    public init(contract: NftCollection.Contract, collectionUid: String, tokenId: String, name: String?, imageUrl: String?, imagePreviewUrl: String?, description: String?, externalLink: String?, permalink: String?, traits: [Trait], lastSalePrice: NftPrice?, onSale: Bool, orders: [NftAssetOrder]) {
        self.contract = contract
        self.collectionUid = collectionUid
        self.tokenId = tokenId
        self.name = name
        self.imageUrl = imageUrl
        self.imagePreviewUrl = imagePreviewUrl
        self.description = description
        self.externalLink = externalLink
        self.permalink = permalink
        self.traits = traits
        self.lastSalePrice = lastSalePrice
        self.onSale = onSale
        self.orders = orders
    }

    public struct Trait: ImmutableMappable {
        public let type: String
        public let value: String
        public let count: Int

        init(type: String, value: String, count: Int) {
            self.type = type
            self.value = value
            self.count = count
        }

        public init(map: Map) throws {
            type = try map.value("type")
            value = try map.value("value")
            count = try map.value("count")
        }

        public func mapping(map: Map) {
            type >>> map["type"]
            value >>> map["value"]
            count >>> map["count"]
        }
    }
}

public struct PagedNftAssets {
    public let assets: [NftAsset]
    public let cursor: String?
}
