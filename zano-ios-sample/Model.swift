//
//  Model.swift
//  zano-ios-sample
//
//  Created by Jumpei Katayama on 2024/11/18.
//

import Foundation
import zano_ios
//// MARK: - Codable
//
public struct SuccessResult: Codable {
    public let returnCode: String
    enum CodingKeys: String, CodingKey {
        case returnCode = "return_code"
    }
}

public struct GetWalletFileResult: Codable {
    // a list of wallet names
    public let items: [String]
    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
}

// MARK: - Wallet Result
public struct WalletResult: Codable {
    public  let name: String
    public  let pass: String
    public  let recentHistory: RecentHistory
    public  let recovered: Bool
    public  let seed: String
    public  let walletFileSize: Int
    public  let walletID: Int
    public  let walletLocalBCSize: Int
    public  let walletInfo: WalletInfo

    enum CodingKeys: String, CodingKey {
        case name, pass, recovered, seed
        case recentHistory = "recent_history"
        case walletFileSize = "wallet_file_size"
        case walletID = "wallet_id"
        case walletLocalBCSize = "wallet_local_bc_size"
        case walletInfo = "wi"
    }
}

// MARK: - Recent History
public struct RecentHistory: Codable {
    public let lastItemIndex: Int
    public let totalHistoryItems: Int

    enum CodingKeys: String, CodingKey {
        case lastItemIndex = "last_item_index"
        case totalHistoryItems = "total_history_items"
    }
}

// MARK: - Wallet Info
public struct WalletInfo: Codable {
    public let address: String
    public let balances: [Balance]
    public let hasBareUnspentOutputs: Bool
    public let isAuditable: Bool
    public let isWatchOnly: Bool
    public let minedTotal: Int
    public let path: String
    public let viewSecKey: String

    enum CodingKeys: String, CodingKey {
        case address, balances
        case hasBareUnspentOutputs = "has_bare_unspent_outputs"
        case isAuditable = "is_auditable"
        case isWatchOnly = "is_watch_only"
        case minedTotal = "mined_total"
        case path
        case viewSecKey = "view_sec_key"
    }
}

// MARK: - Balance
public struct Balance: Codable {
    public let assetInfo: AssetInfo
    public let awaitingIn: Int
    public let awaitingOut: Int
    public let total: Int
    public let unlocked: Int

    enum CodingKeys: String, CodingKey {
        case assetInfo = "asset_info"
        case awaitingIn = "awaiting_in"
        case awaitingOut = "awaiting_out"
        case total, unlocked
    }
}

// MARK: - Asset Info
public struct AssetInfo: Codable {
    public let assetID: String
    public let currentSupply: Int
    public let decimalPoint: Int
    public let fullName: String
    public let hiddenSupply: Bool
    public let metaInfo: String
    public let owner: String
    public let ticker: String
    public let totalMaxSupply: Int

    enum CodingKeys: String, CodingKey {
        case assetID = "asset_id"
        case currentSupply = "current_supply"
        case decimalPoint = "decimal_point"
        case fullName = "full_name"
        case hiddenSupply = "hidden_supply"
        case metaInfo = "meta_info"
        case owner, ticker
        case totalMaxSupply = "total_max_supply"
    }
}

public struct JobResult: Codable {
    public let jobId: UInt64

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
    }
}

public struct AddressInfo: Codable {
    public let valid: Bool
    public let auditable: Bool
    public let paymentId: Bool
    public let wrap: Bool

    enum CodingKeys: String, CodingKey {
        case valid
        case auditable
        case paymentId = "payment_id"
        case wrap
    }
}

public struct AsyncResult: Codable {
    public let status: AsyncSatus
    public let result: RPCResponse?
}

public struct AsyncOpenSuccessResponse: Codable {
    public let status: AsyncSatus
    public let walletResult: WalletResult?

    public static func create(asyncResult: AsyncResult) throws -> AsyncOpenSuccessResponse {
        if asyncResult.result == nil {
            return AsyncOpenSuccessResponse(status: asyncResult.status, walletResult: nil)
        } else if let walletResult = try? asyncResult.result?.result?.get(WalletResult.self) {
            return AsyncOpenSuccessResponse(status: asyncResult.status, walletResult: walletResult)
        } else if let error = asyncResult.result?.error {
            throw ZANOError.asyncErrorResponse(status: asyncResult.status.rawValue, code: error.code, message: error.message)
        }
        throw ZANOError.unknown(message: "result is nil")
    }
}

public enum AsyncSatus: String, Codable {
    case delivered
    case idle
    case canceled
}


// MARK: - StatusModel
public struct ConnectivityStatus: Codable {
    public let isOnline: Bool
    public let isServerBusy: Bool
    public let lastDaemonIsDisconnected: Bool
    public let lastProxyCommunicateTimestamp: Int

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case isOnline = "is_online"
        case isServerBusy = "is_server_busy"
        case lastDaemonIsDisconnected = "last_daemon_is_disconnected"
        case lastProxyCommunicateTimestamp = "last_proxy_communicate_timestamp"
    }
}


public struct BalanceResult: Codable {
    public let balance: Int
    public let balances: [Balance]
    public let unlocked_balance: Int
}


struct TransferResponse: Codable {
    let txHash: String
    let txSize: Int
    let txUnsignedHex: String
    
    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
        case txSize = "tx_size"
        case txUnsignedHex = "tx_unsigned_hex"
    }
}

public struct WalletSyncStatus: Codable {
    public let currentDaemonHeight: Int
    public let currentWalletHeight: Int
    public let isDaemonConnected: Bool
    public let isInLongRefresh: Bool
    public let progress: Int
    public let walletState: Int

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case currentDaemonHeight = "current_daemon_height"
        case currentWalletHeight = "current_wallet_height"
        case isDaemonConnected = "is_daemon_connected"
        case isInLongRefresh = "is_in_long_refresh"
        case progress
        case walletState = "wallet_state"
    }
}

public struct WorkingDir {
    public static var dir: String? {
        let fileManager = FileManager.default

        if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return docsDir.path
        } else {
            return nil
        }
    }
}

public struct ZANOConst {
    public static let ZANO_TESTNET_IP = "195.201.107.230"
    public static let ZANO_TESTNET_PORT = "33336"
    public static let TEST_WALLET_NAME = "testWallet1"
    public static let TEST_WALLET_PASSWORD = "testWalletPassword"
    public static let TEST_WALLET_SEED =
        "insult understand back vein peaceful somewhere bare deeply anyone hunger wait prince shoot grip scream bowl mama card dread less sadness angry explore almost worry dim"
    public static let TEST_WALLET_ADDRESS =
        "ZxCx5QqAh67JwX7F2hs7M2FcJ3bcLEhWfb2yqiofDeWn67guYBA4fwb1ekbsp7vZid35fVJtY6E2iiWVUJWRkyQu1Mchqr3iE"
    public static let ZANO_MAINNET_IP = "195.201.107.230"
    public static let ZANO_MAINNET_PORT = "33340"
    public static let TEST_WALLET_NAME_2 = "testWallet2"
    public static let TEST_WALLET_PASSWORD_2 = "testWalletPassword2"
}

// MARK: = Prser

public struct JSONRPCParser {
    public static func parseResponse<T: Codable>(jsonData: Data, resultType: T.Type) throws -> T {
        let decodedResponse = try JSONDecoder().decode(RPCResponse.self, from: jsonData)
        
        if let result = decodedResponse.result {
            // Return success with the parsed result
            return try result.get(T.self)
        } else if let error = decodedResponse.error {
            // Return failure with the error
            throw ZANOError.errorResponse(code: error.code, message: error.message)
        } else {
            throw ZANOError.unknown(message: "")
        }
    }
    
    public static func parseJsonResponse<T: Codable>(jsonData: Data, resultType: T.Type) throws -> T {
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}


