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
        XCTAssertEqual(ZanoWallet.get_version(), "2.0.0.336[132d2bf]")
    }
    
    func testHelloWorld() throws {
        XCTAssertEqual(HelloWorld.test(), "This is a test string from ZanoString.")
    }
    
    func testGetWalletFiles() throws {
        XCTAssertEqual(ZanoWallet.get_wallet_files().data(using: .utf8)?.base64EncodedString(), "ew0KfQ==")
    }
    
    func testGetLogsBuffer() throws {
        XCTAssertEqual(ZanoWallet.get_logs_buffer(), "")
    }
    
    func testGetOpenedWallets() throws {
        XCTAssertEqual(ZanoWallet.get_opened_wallets().data(using: .utf8)?.base64EncodedString(), "ew0KICAiaWQiOiAwLA0KICAianNvbnJwYyI6ICIiLA0KICAicmVzdWx0Ijogew0KICAgICJyZXR1cm5fY29kZSI6ICJVTklOSVRJQUxJWkVEIg0KICB9DQp9")
    }

    func testTruncateLog() throws {
        XCTAssertEqual(ZanoWallet.truncate_log().data(using: .utf8)?.base64EncodedString(), "ew0KICAiaWQiOiAwLA0KICAianNvbnJwYyI6ICIiLA0KICAicmVzdWx0Ijogew0KICAgICJyZXR1cm5fY29kZSI6ICJPSyINCiAgfQ0KfQ==")
    }

    func testInitIpPort() throws {
        let hoge = ZanoWallet.InitIpPort("", "", "", 0).data(using: .utf8)?.base64EncodedString()
        XCTAssertEqual(hoge, "ew0KICAiZXJyb3IiOiB7DQogICAgImNvZGUiOiAiSU5URVJOQUxfRVJST1IiLA0KICAgICJtZXNzYWdlIjogIltpbml0XSBAIFwvVXNlcnNcL3Jva3lcL3Byb2plY3RzXC9aYW5vXC9tb2JpbGVfcmVwb1wvbW9iaWxlXC96YW5vX25hdGl2ZV9saWJcL3phbm9cL3NyY1wvd2FsbGV0XC9wbGFpbl93YWxsZXRfYXBpLmNwcDoyMzcgXG5tZXNzYWdlOlJlYWQtb25seSBmaWxlIHN5c3RlbSINCiAgfSwNCiAgImlkIjogMCwNCiAgImpzb25ycGMiOiAiIiwNCiAgIm1ldGhvZCI6ICIiDQp9")
    }

}
