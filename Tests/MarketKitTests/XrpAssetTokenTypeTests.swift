@testable import MarketKit
import XCTest

final class XrpAssetTokenTypeTests: XCTestCase {
    private let rlusd = TokenType.xrpAsset(currency: "524C555344000000000000000000000000000000", issuer: "rMxCKbEDwqr76QuheSUMdEGf4B9xJ8m5De")
    private let usd = TokenType.xrpAsset(currency: "USD", issuer: "rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq")

    func testXrpBlockchainTypeRoundTrip() {
        XCTAssertEqual(BlockchainType(uid: "xrp"), .xrp)
        XCTAssertEqual(BlockchainType.xrp.uid, "xrp")
    }

    func testIdRoundTrip() {
        XCTAssertEqual(rlusd.id, "xrp:524C555344000000000000000000000000000000-rMxCKbEDwqr76QuheSUMdEGf4B9xJ8m5De")
        XCTAssertEqual(TokenType(id: rlusd.id), rlusd)
        XCTAssertEqual(usd.id, "xrp:USD-rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq")
        XCTAssertEqual(TokenType(id: usd.id), usd)
    }

    func testApiValuesRoundTrip() {
        let values = rlusd.values
        XCTAssertEqual(values.type, "xrp")
        XCTAssertEqual(values.reference, "524C555344000000000000000000000000000000-rMxCKbEDwqr76QuheSUMdEGf4B9xJ8m5De")
        XCTAssertEqual(TokenType(type: values.type, reference: values.reference), rlusd)
    }

    func testInvalidReferenceIsUnsupportedOrNil() {
        XCTAssertNil(TokenType(id: "xrp:USD"))
        XCTAssertNil(TokenType(id: "xrp:-rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq"))
        XCTAssertNil(TokenType(id: "xrp:USD-"))
        XCTAssertEqual(TokenType(type: "xrp", reference: "USD"), .unsupported(type: "xrp", reference: "USD"))
        XCTAssertEqual(TokenType(type: "xrp", reference: nil), .unsupported(type: "xrp", reference: nil))
    }

    func testNativeXrpMetadata() throws {
        let kit = try Kit.instance(hsApiBaseUrl: "https://example.com")
        let token = try XCTUnwrap(kit.token(query: TokenQuery(blockchainType: .xrp, tokenType: .native)))

        XCTAssertEqual(token.coin.uid, "ripple")
        XCTAssertEqual(token.coin.code, "XRP")
        XCTAssertEqual(token.type, .native)
        XCTAssertEqual(token.decimals, 6)
    }
}
