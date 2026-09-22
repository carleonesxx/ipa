import XCTest
@testable import Fitly

final class FITLYTests: XCTestCase {
    func testKeychainRoundTrip() throws {
        let keychain = KeychainStore(); try keychain.save("token", key: "fitly.test"); XCTAssertEqual(keychain.read("fitly.test"), "token"); keychain.delete("fitly.test")
    }
    func testMockHealthProviderReturnsZeroState() async throws {
        #if DEBUG
        let snapshot = try await MockHealthProvider().readToday(); XCTAssertEqual(snapshot.steps, 0); XCTAssertEqual(snapshot.source, "mock")
        #endif
    }
}
