class ExchangeManager {
    private let storage: ExchangeStorage

    init(storage: ExchangeStorage) {
        self.storage = storage
    }

}

extension ExchangeManager {

    func imageUrlsMap(ids: [String]) -> [String: String] {
        do {
            let exchanges = try storage.exchanges(ids: ids)
            var imageUrls = [String: String]()

            for exchange in exchanges {
                imageUrls[exchange.id] = exchange.imageUrl
            }

            return imageUrls
        } catch {
            return [:]
        }
    }

    func handleFetched(exchanges: [Exchange]) {
        do {
            try storage.update(exchanges: exchanges)
        } catch {
            // todo
        }
    }

}
