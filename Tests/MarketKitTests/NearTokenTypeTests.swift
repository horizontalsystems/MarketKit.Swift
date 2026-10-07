@testable import MarketKit
import XCTest

final class NearTokenTypeTests: XCTestCase {
    private let wnear = TokenType.nep141(contractId: "wrap.near")
    private let usdc = TokenType.nep141(contractId: "17208628f84f5d6ad33f0da3bbbeb27ffcb398eac501a31bd6ad2011e36133a1")

    func testNearBlockchainTypeRoundTrip() {
        XCTAssertEqual(BlockchainType(uid: "near-protocol"), .near)
        XCTAssertEqual(BlockchainType.near.uid, "near-protocol")
    }

    func testIdRoundTrip() {
        XCTAssertEqual(wnear.id, "near-protocol:wrap.near")
        XCTAssertEqual(TokenType(id: wnear.id), wnear)
        XCTAssertEqual(usdc.id, "near-protocol:17208628f84f5d6ad33f0da3bbbeb27ffcb398eac501a31bd6ad2011e36133a1")
        XCTAssertEqual(TokenType(id: usdc.id), usdc)
    }

    func testTokenQueryIdRoundTrip() {
        XCTAssertEqual(TokenQuery(blockchainType: .near, tokenType: wnear).id, "near-protocol|near-protocol:wrap.near")
        XCTAssertEqual(TokenQuery(id: "near-protocol|native"), TokenQuery(blockchainType: .near, tokenType: .native))
    }

    func testApiValuesRoundTrip() {
        let values = wnear.values
        XCTAssertEqual(values.type, "near-protocol")
        XCTAssertEqual(values.reference, "wrap.near")
        XCTAssertEqual(TokenType(type: values.type, reference: values.reference), wnear)
    }

    func testEmptyReferenceIsUnsupportedOrNil() {
        XCTAssertNil(TokenType(id: "near-protocol:"))
        XCTAssertEqual(TokenType(type: "near-protocol", reference: ""), .unsupported(type: "near-protocol", reference: ""))
        XCTAssertEqual(TokenType(type: "near-protocol", reference: nil), .unsupported(type: "near-protocol", reference: nil))
    }
}
