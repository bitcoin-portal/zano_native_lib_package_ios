//
//  Model.swift
//  zano-ios
//
//  Created by Jumpei Katayama on 2024/10/17.
//

import Foundation

public enum ZANOError: Error {
    case errorResponse(code: String, message: String)
    case asyncErrorResponse(status: String, code: String, message: String)
    case unknown(message: String)
    case conversionFailure(message: String)
}


// MARK: - Codable

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
    public let jobId: String

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
    public let result: RPCResponse
    
    public var success: AsyncSuccessResponse? {
        if let balanceResult = try? result.result?.get(BalanceResult.self) {
            return AsyncSuccessResponse(status: status, balance: balanceResult)
        }
        return nil
    }
    
    public var error: JSONRPCError? {
        return result.error
    }
}

public struct AsyncSuccessResponse: Codable {
    public let status: AsyncSatus
    public let balance: BalanceResult
    
    public static func create(asyncResult: AsyncResult) throws -> AsyncSuccessResponse {
        if let balanceResult = try? asyncResult.result.result?.get(BalanceResult.self) {
            return AsyncSuccessResponse(status: asyncResult.status, balance: balanceResult)
        } else if let error = asyncResult.result.error {
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
