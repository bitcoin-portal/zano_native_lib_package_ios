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
        XCTAssertEqual(ZanoWallet.getVersion(), "2.0.0.336[132d2bf]")
    }
    
    func testHelloWorld() throws {
        XCTAssertEqual(HelloWorld.test(), "This is a test string from ZanoString.")
    }

    func testGetLogsBuffer() throws {
        XCTAssertEqual(ZanoWallet.getLogsBuffer(), "")
    }
    
    func testTruncateLog() throws {
        let result = ZanoWallet.truncateLog()
        XCTAssertEqual(result, "OK")
    }

    func testInit() throws {
        let fileManager = FileManager.default

        let docsDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        let result = ZanoWallet.InitIpPort(ip: "195.201.107.230", port: "33336", working_dir: docsDir.path, log_level: 0)
        XCTAssertEqual(result, "OK")
    }
    
    func testGetTransactionFee() throws {
        let fee = ZanoWallet.getCurrentTxFee(priority: 0)
        XCTAssertEqual(fee, 10000000000)
    }
}


//class ParseTests: XCTestCase {
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//    
//    func testGetWalletResult() throws {
//        let encoded = mockGetWalletFiles.data(using: .utf8)!
//        let walletResponse = try JSONRPCParser.parseJsonResponse(jsonData: encoded, resultType: GetWalletFileResult.self)
//        XCTAssertEqual(walletResponse.items.count, 2)
//        XCTAssertEqual(walletResponse.items.first ?? "", "my zano wallet")
//        XCTAssertEqual(walletResponse.items.last ?? "", "my zano wallet2")
//    }
//    
//    
//    func testWalletInfo() throws {
//        let encoded = mockWalletResult.data(using: .utf8)!
//        let walletResponse = try JSONRPCParser.parseResponse(jsonData: encoded, resultType: WalletResult.self)
//        XCTAssertEqual(walletResponse.name, "")
//        XCTAssertEqual(walletResponse.pass, "")
//        XCTAssertFalse(walletResponse.recovered)
//        XCTAssertEqual(walletResponse.seed, "kitchen patience fully might bit worthless lead early language ghost blue look heel outside crumble creation everytime replace painful hidden underneath grew understand horizon war replace")
//        XCTAssertEqual(walletResponse.walletFileSize, 0)
//        XCTAssertEqual(walletResponse.walletID, 0)
//        XCTAssertEqual(walletResponse.walletLocalBCSize, 0)
//        XCTAssertEqual(walletResponse.walletInfo.address, "ZxCW6Gtijrh5Z5onFNW66hVZoBi5P3X4XJ5rBqafTMuUgoUrvu6XxYSHdg3VWniVf97kHozLKj7MgcA9PdwJPZNL1SwivnU7t")
//        XCTAssertEqual(walletResponse.recentHistory.lastItemIndex, 0)
//        XCTAssertEqual(walletResponse.recentHistory.totalHistoryItems, 0)
//        XCTAssertEqual(walletResponse.walletInfo.balances.count, 1)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.assetID, "d6329b5b1f7c0805b5c345f4957554002a2f557845f64d7645dae0e051a6498a")
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.currentSupply, 0)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.decimalPoint, 12)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.fullName, "Zano")
//        XCTAssertFalse(walletResponse.walletInfo.balances.first!.assetInfo.hiddenSupply)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.currentSupply, 0)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.metaInfo, "")
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.ticker, "ZANO")
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.assetInfo.totalMaxSupply, 0)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.awaitingIn, 0)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.awaitingOut, 0)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.total, 0)
//        XCTAssertEqual(walletResponse.walletInfo.balances.first!.unlocked, 0)
//        XCTAssertFalse(walletResponse.walletInfo.hasBareUnspentOutputs)
//        XCTAssertFalse(walletResponse.walletInfo.isAuditable)
//        XCTAssertFalse(walletResponse.walletInfo.isWatchOnly)
//        XCTAssertEqual(walletResponse.walletInfo.minedTotal, 0)
//        XCTAssertEqual(walletResponse.walletInfo.path, "/Users/user/Library/Developer/CoreSimulator/Devices/11C27930-183C-4F19-BDDB-0AF90C77BC14/data/Containers/Data/Application/FCF6C287-4A4A-4EB0-BDE6-B292A1A3B39E/Documents/wallets/testWallet1")
//        XCTAssertEqual(walletResponse.walletInfo.viewSecKey, "7149d1f592ed7e03719e7451a23ebf2250016384f4d7cf057241544648fe4d01")
//    }
//    
//    func testAsyncResponseIdle() throws {
//        let encoded = mockAsyncResponseIdle.data(using: .utf8)!
//        let asyncResult = try JSONRPCParser.parseJsonResponse(jsonData: encoded, resultType: AsyncOpenSuccessResponse.self)
//        XCTAssertEqual(asyncResult.status, .idle)
//    }
//
//    
////    func testAsyncResponseSuccess() throws {
////        let encoded = mockAsyncResponse.data(using: .utf8)!
////        let syncSuccessResponse = try JSONRPCParser.parseJsonResponse(jsonData: encoded, resultType: AsyncOpenSuccessResponse.self)
//////        let syncSuccessResponse = try AsyncSuccessResponse.create(asyncResult: asyncResult)
////        XCTAssertEqual(syncSuccessResponse.status, .delivered)
////        XCTAssertEqual(syncSuccessResponse.walletResult.balance, 4990000000000)
////        XCTAssertEqual(syncSuccessResponse.balance?.balances.count, 1)
////        let balance = syncSuccessResponse.balance!.balances.first!
////        XCTAssertEqual(balance.awaitingIn, 0)
////        XCTAssertEqual(balance.awaitingOut, 0)
////        XCTAssertEqual(balance.total, 5000000000000)
////        XCTAssertEqual(balance.unlocked, 4990000000000)
////        XCTAssertEqual(balance.assetInfo.currentSupply, 0)
////        XCTAssertEqual(balance.assetInfo.decimalPoint, 12)
////        XCTAssertEqual(balance.assetInfo.fullName, "Zano")
////        XCTAssertFalse(balance.assetInfo.hiddenSupply)
////        XCTAssertEqual(balance.assetInfo.metaInfo, "")
////        XCTAssertEqual(balance.assetInfo.owner, "0000000000000000000000000000000000000000000000000000000000000000")
////        XCTAssertEqual(balance.assetInfo.ticker, "ZANO")
////        XCTAssertEqual(balance.assetInfo.totalMaxSupply, 0)
////        XCTAssertEqual(syncSuccessResponse.balance?.unlocked_balance, 4990000000000)
////    }
////    
//    func testAsyncOpenResponseSuccess() throws {
//        let encoded = mockAsyncOpenWalletSuccessResponse.data(using: .utf8)!
//        let asyncResult = try JSONRPCParser.parseJsonResponse(jsonData: encoded, resultType: AsyncResult.self)
//        let syncSuccessResponse = try AsyncOpenSuccessResponse.create(asyncResult: asyncResult)
//        XCTAssertEqual(syncSuccessResponse.status, .delivered)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.name, "")
//        XCTAssertEqual(syncSuccessResponse.walletResult?.pass, "")
//        XCTAssertFalse(syncSuccessResponse.walletResult?.recovered ?? true)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.seed, "kitchen patience fully might bit worthless lead early language ghost blue look heel outside crumble creation everytime replace painful hidden underneath grew understand horizon war replace")
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletFileSize, 528)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletID, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletLocalBCSize, 1)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.address, "ZxCW6Gtijrh5Z5onFNW66hVZoBi5P3X4XJ5rBqafTMuUgoUrvu6XxYSHdg3VWniVf97kHozLKj7MgcA9PdwJPZNL1SwivnU7t")
//        XCTAssertEqual(syncSuccessResponse.walletResult?.recentHistory.lastItemIndex, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.recentHistory.totalHistoryItems, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.count, 1)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.assetID, "d6329b5b1f7c0805b5c345f4957554002a2f557845f64d7645dae0e051a6498a")
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.currentSupply, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.decimalPoint, 12)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.fullName, "Zano")
//        XCTAssertFalse(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.hiddenSupply ?? true)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.currentSupply, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.metaInfo, "")
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.ticker, "ZANO")
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.assetInfo.totalMaxSupply, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.awaitingIn, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.awaitingOut, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.total, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.balances.first!.unlocked, 0)
//        XCTAssertFalse(syncSuccessResponse.walletResult?.walletInfo.hasBareUnspentOutputs ?? true)
//        XCTAssertFalse(syncSuccessResponse.walletResult?.walletInfo.isAuditable ?? true)
//        XCTAssertFalse(syncSuccessResponse.walletResult?.walletInfo.isWatchOnly ?? true)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.minedTotal, 0)
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.path, "/Users/user/Library/Developer/CoreSimulator/Devices/11C27930-183C-4F19-BDDB-0AF90C77BC14/data/Containers/Data/Application/8A192E13-38E8-462C-B5C0-3D262552F8BC/Documents/wallets/testWallet1")
//        XCTAssertEqual(syncSuccessResponse.walletResult?.walletInfo.viewSecKey, "7149d1f592ed7e03719e7451a23ebf2250016384f4d7cf057241544648fe4d01")
//    }
//
//
//    func testWalletStatus() throws {
//        let encoded = mockWalletStatus.data(using: .utf8)!
//        let result = try JSONRPCParser.parseJsonResponse(jsonData: encoded, resultType: WalletSyncStatus.self)
//        XCTAssertEqual(result.progress, 0)
//        XCTAssertEqual(result.currentDaemonHeight, 2809788)
//        XCTAssertEqual(result.currentWalletHeight, 2282031)
//        XCTAssertTrue(result.isDaemonConnected)
//        XCTAssertTrue(result.isInLongRefresh)
//        XCTAssertEqual(result.walletState, 1)
//    }
//
//    
//    var mockWalletStatus: String {
//        return """
//        {
//          "current_daemon_height": 2809788,
//          "current_wallet_height": 2282031,
//          "is_daemon_connected": true,
//          "is_in_long_refresh": true,
//          "progress": 0,
//          "wallet_state": 1
//        }
//        """
//    }
//    
//    var mockAsyncResponseIdle: String {
//        return """
//         {"status": "idle"}
//        """
//    }
//        
//    var mockAsyncResponse: String {
//        return """
// {"status": "delivered", "result": {
//        "id": 0,
//        "jsonrpc": "2.0",
//        "result": {
//          "balance": 4990000000000,
//          "balances": [{
//            "asset_info": {
//              "asset_id": "d6329b5b1f7c0805b5c345f4957554002a2f557845f64d7645dae0e051a6498a",
//              "current_supply": 0,
//              "decimal_point": 12,
//              "full_name": "Zano",
//              "hidden_supply": false,
//              "meta_info": "",
//              "owner": "0000000000000000000000000000000000000000000000000000000000000000",
//              "ticker": "ZANO",
//              "total_max_supply": 0
//            },
//            "awaiting_in": 0,
//            "awaiting_out": 0,
//            "total": 5000000000000,
//            "unlocked": 4990000000000
//          }],
//          "unlocked_balance": 4990000000000
//        }
//      }  }
// """
//    }
//    
//    var mockAsyncOpenWalletSuccessResponse: String {
//        return """
// {
//   "status": "delivered",
//   "result": {
//     "id": 0,
//     "jsonrpc": "",
//     "result": {
//       "name": "",
//       "pass": "",
//       "recent_history": {
//         "last_item_index": 0,
//         "total_history_items": 0
//       },
//       "recovered": false,
//       "seed": "kitchen patience fully might bit worthless lead early language ghost blue look heel outside crumble creation everytime replace painful hidden underneath grew understand horizon war replace",
//       "wallet_file_size": 528,
//       "wallet_id": 0,
//       "wallet_local_bc_size": 1,
//       "wi": {
//         "address": "ZxCW6Gtijrh5Z5onFNW66hVZoBi5P3X4XJ5rBqafTMuUgoUrvu6XxYSHdg3VWniVf97kHozLKj7MgcA9PdwJPZNL1SwivnU7t",
//         "balances": [
//           {
//             "asset_info": {
//               "asset_id": "d6329b5b1f7c0805b5c345f4957554002a2f557845f64d7645dae0e051a6498a",
//               "current_supply": 0,
//               "decimal_point": 12,
//               "full_name": "Zano",
//               "hidden_supply": false,
//               "meta_info": "",
//               "owner": "0000000000000000000000000000000000000000000000000000000000000000",
//               "ticker": "ZANO",
//               "total_max_supply": 0
//             },
//             "awaiting_in": 0,
//             "awaiting_out": 0,
//             "total": 0,
//             "unlocked": 0
//           }
//         ],
//         "has_bare_unspent_outputs": false,
//         "is_auditable": false,
//         "is_watch_only": false,
//         "mined_total": 0,
//         "path": "/Users/user/Library/Developer/CoreSimulator/Devices/11C27930-183C-4F19-BDDB-0AF90C77BC14/data/Containers/Data/Application/8A192E13-38E8-462C-B5C0-3D262552F8BC/Documents/wallets/testWallet1",
//         "view_sec_key": "7149d1f592ed7e03719e7451a23ebf2250016384f4d7cf057241544648fe4d01"
//       }
//     }
//   }
// }
// """
//    }
//
//    
//    var mockConnectivityStatus: String {
//        return """
//        {
//          "is_online": true,
//          "is_server_busy": false,
//          "last_daemon_is_disconnected": false,
//          "last_proxy_communicate_timestamp": 1726314483
//        }
//"""
//    }
//    
//    var mockGetWalletFiles: String {
//        return """
//         {
//          "items": [
//            "my zano wallet",
//            "my zano wallet2"
//          ]
//        }
//        """
//    }
//
//    var mockWalletResult: String {
//        return """
//     {
//       "id": 0,
//       "jsonrpc": "",
//       "result": {
//         "name": "",
//         "pass": "",
//         "recent_history": {
//           "last_item_index": 0,
//           "total_history_items": 0
//         },
//         "recovered": false,
//         "seed": "kitchen patience fully might bit worthless lead early language ghost blue look heel outside crumble creation everytime replace painful hidden underneath grew understand horizon war replace",
//         "wallet_file_size": 0,
//         "wallet_id": 0,
//         "wallet_local_bc_size": 0,
//         "wi": {
//           "address": "ZxCW6Gtijrh5Z5onFNW66hVZoBi5P3X4XJ5rBqafTMuUgoUrvu6XxYSHdg3VWniVf97kHozLKj7MgcA9PdwJPZNL1SwivnU7t",
//           "balances": [
//             {
//               "asset_info": {
//                 "asset_id": "d6329b5b1f7c0805b5c345f4957554002a2f557845f64d7645dae0e051a6498a",
//                 "current_supply": 0,
//                 "decimal_point": 12,
//                 "full_name": "Zano",
//                 "hidden_supply": false,
//                 "meta_info": "",
//                 "owner": "0000000000000000000000000000000000000000000000000000000000000000",
//                 "ticker": "ZANO",
//                 "total_max_supply": 0
//               },
//               "awaiting_in": 0,
//               "awaiting_out": 0,
//               "total": 0,
//               "unlocked": 0
//             }
//           ],
//           "has_bare_unspent_outputs": false,
//           "is_auditable": false,
//           "is_watch_only": false,
//           "mined_total": 0,
//           "path": "/Users/user/Library/Developer/CoreSimulator/Devices/11C27930-183C-4F19-BDDB-0AF90C77BC14/data/Containers/Data/Application/FCF6C287-4A4A-4EB0-BDE6-B292A1A3B39E/Documents/wallets/testWallet1",
//           "view_sec_key": "7149d1f592ed7e03719e7451a23ebf2250016384f4d7cf057241544648fe4d01"
//         }
//       }
//     }
//
//"""
//    }
//}


