import ObjectMapper

public struct NftCollection {
    public let contracts: [Contract]
    public let uid: String
    public let name: String
    public let description: String?
    public let imageUrl: String?
    public let featuredImageUrl: String?
    public let externalUrl: String?
    public let discordUrl: String?
    public let twitterUsername: String?

    public let stats: NftCollectionStats
    public let statCharts: NftCollectionStatCharts?

    public init(contracts: [Contract], uid: String, name: String, description: String?, imageUrl: String?, featuredImageUrl: String?, externalUrl: String?, discordUrl: String?, twitterUsername: String?, stats: NftCollectionStats, statCharts: NftCollectionStatCharts?) {
        self.contracts = contracts
        self.uid = uid
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.featuredImageUrl = featuredImageUrl
        self.externalUrl = externalUrl
        self.discordUrl = discordUrl
        self.twitterUsername = twitterUsername
        self.stats = stats
        self.statCharts = statCharts
    }

    public struct Contract: ImmutableMappable {
        public let address: String
        public let schemaName: String

        public init(address: String, schemaName: String) {
            self.address = address
            self.schemaName = schemaName
        }

        public init(map: Map) throws {
            address = try map.value("address")
            schemaName = try map.value("schema_name")
        }

        public func mapping(map: Map) {
            address >>> map["address"]
            schemaName >>> map["schema_name"]
        }
    }
}

public struct NftAssetCollection {
    public let collections: [NftCollection]
    public let assets: [NftAsset]

    public init(collections: [NftCollection], assets: [NftAsset]) {
        self.collections = collections
        self.assets = assets
    }

    public static var empty: NftAssetCollection {
        NftAssetCollection(collections: [], assets: [])
    }
}
