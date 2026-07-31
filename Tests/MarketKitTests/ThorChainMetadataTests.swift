import XCTest
@testable import MarketKit

final class ThorChainMetadataTests: XCTestCase {
    func testThorChainTypeRoundTrip() {
        XCTAssertEqual(BlockchainType(uid: "thorchain"), .thorChain)
        XCTAssertEqual(BlockchainType.thorChain.uid, "thorchain")
    }

    func testNativeRuneMetadata() throws {
        let kit = try Kit.instance(hsApiBaseUrl: "https://example.com")
        let token = try XCTUnwrap(kit.token(query: TokenQuery(blockchainType: .thorChain, tokenType: .native)))

        XCTAssertEqual(token.coin.uid, "thorchain")
        XCTAssertEqual(token.coin.code, "RUNE")
        XCTAssertEqual(token.type, .native)
        XCTAssertEqual(token.decimals, 8)
    }
}
