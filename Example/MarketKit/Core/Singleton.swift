import MarketKit

class Singleton {
    static let instance = Singleton()

    let kit: Kit

    init() {
        kit = try! Kit.instance(minLogLevel: .debug)

        kit.sync()
    }

}
