//
//  zano_iosTests.swift
//  zano-iosTests
//
//  Created by Jumpei Katayama on 2024/09/13.
//

import XCTest
import zano_ios

class zano_iosTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testZANOVerssion() throws {
        XCTAssertEqual(ZanoWallet.get_versionCpp(), "2.0.0.336[132d2bf]")
    }
}
