//
//  zano.swift
//  zano-ios
//
//  Created by Jumpei Katayama on 2024/09/13.
//

import Foundation
public typealias ZANOString = UnsafeRawPointer

public var asyncCallMethods: [String] {
    return [
        "close",
        "open",
        "restore",
        "get_seed_phrase_info",
        "invoke",// (this is proxy to wallet JSON RPC API, documented in the official documentation)
        "get_wallet_status"
    ]
}

public enum ZanoWallet {
    // MARK: - Initialization Functions
    public static func InitIpPort(ip: String, port: String, working_dir: String, log_level:Int32) throws -> SuccessResult {
        debugPrint("ip is \(ip)")
        debugPrint("port is \(port)")
        debugPrint("working_dir is \(working_dir)")
        debugPrint("log_level is \(log_level)")
        let ipCpp = StringConversionUtils.swiftStringToCppString(ip)
        let portCpp = StringConversionUtils.swiftStringToCppString(port)
        let workingDirRawCpp = StringConversionUtils.swiftStringToCppString(working_dir)
        debugPrint("ipCpp is \(ipCpp)")
        debugPrint("portCpp is \(portCpp)")
        debugPrint("workingDirRawCpp is \(workingDirRawCpp)")
        let jsonStr = String(ZanoCore.initIpPort(ipCpp, portCpp, workingDirRawCpp, log_level))
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: SuccessResult.self)
        return result
        
    }
    
    // MARK: - Utility Functions
    public static func reset() throws -> SuccessResult {
        
        let jsonStr = String(ZanoCore.reset())
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: SuccessResult.self)
        return result
    }
    
    public static func getVersion() -> String {
        String(ZanoCore.get_version())
    }
    
    public static func getWalletFiles() throws -> GetWalletFileResult {
        let jsonStr = String(ZanoCore.get_wallet_files())
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: GetWalletFileResult.self)
        return result
    }
    
    public static func deleteWallet(file_name: String) throws -> SuccessResult {
        let fileName = StringConversionUtils.swiftStringToCppString(file_name)
        let jsonStr = String(ZanoCore.delete_wallet(fileName))
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: SuccessResult.self)
        return result
    }
    
    public static func getAddressInfo(addr: String) throws -> AddressInfo {
        let address = StringConversionUtils.swiftStringToCppString(addr)
        let jsonStr = String(ZanoCore.get_address_info(address))
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: AddressInfo.self)
        return result
    }
    
    // MARK: - Configuration Functions
    public static func getLogsBuffer() -> String {
        String(ZanoCore.get_logs_buffer())
    }
    
    public static func truncateLog() throws -> SuccessResult {
        let jsonStr = String(ZanoCore.truncate_log())
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: SuccessResult.self)
        return result
    }
    
    public static func getConnectivityStatus() throws -> ConnectivityStatus {
        let jsonStr = String(ZanoCore.get_connectivity_status())
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: ConnectivityStatus.self)
        return result
    }
    
    // MARK: - Wallet Management Functions
    public static func restore(seed: String, walletName: String, password: String, seed_password:String) throws -> WalletResult {
        let sd = StringConversionUtils.swiftStringToCppString(seed)
        let pa = StringConversionUtils.swiftStringToCppString(walletName)
        let ps = StringConversionUtils.swiftStringToCppString(password)
        let sdps = StringConversionUtils.swiftStringToCppString(seed_password)
        
        
        debugPrint("seed is \(sd)")
        debugPrint("walletName is \(pa)")
        debugPrint("ps is \(ps)")
        debugPrint("sdps is \(sdps)")
        let jsonStr = String(ZanoCore.restore(sd, pa, ps, sdps))
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: WalletResult.self)
        return result
    }
    
    // Create a new wallet
    // https://github.com/hyle-team/zano_mobile/blob/6cf344ee1d1b8f462c9339cce5054bc1fd2790b8/src/cpp/zano_wallet_interface_impl.cxx#L74
    // generate_new_wallet
    public static func generate(walletName: String, password: String) throws -> WalletResult {
        let name = StringConversionUtils.swiftStringToCppString(walletName)
        let ps = StringConversionUtils.swiftStringToCppString(password)
        let jsonStr = String(ZanoCore.generate(name, ps))
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: WalletResult.self)
        return result
    }
    
    // not working?
    public static func getOpenedWallets() throws -> [WalletResult] {
        let jsonStr = String(ZanoCore.get_opened_wallets())
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: [WalletResult].self)
        return result
    }
    
    
    /*
     "close"
     "open",
     "restore"
     "get_seed_phrase_info",
     "invoke" (this is proxy to wallet JSON RPC API, documented in the official documentation)
     "get_wallet_status"
     
     */
    
    // MARK: - Asynchronous API Functions
    
    public static func asyncCall(methodName: String, walletId: UInt64, params: String) async throws -> JobResult {
        guard asyncCallMethods.contains(methodName) else {
            throw ZANOError.unknown(message: "unsupported method name")
        }
        
        let name = StringConversionUtils.swiftStringToCppString(methodName)
        let param = StringConversionUtils.swiftStringToCppString(params)
        
        
        let jsonStr = String(ZanoCore.async_call(name, walletId, param))
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: JobResult.self)
        return result
    }
    // MARK:  Wallet Operations
    public static func asyncGetWalletStatus(jobId: UInt64) async throws -> WalletSyncStatus {
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: WalletSyncStatus.self)
        return result
    }

    
    public static func asyncRestore(jobId: UInt64) async throws -> WalletResult {
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: WalletResult.self)
        return result
    }
    
    // https://docs.zano.org/docs/build/rpc-api/wallet-rpc-api/getbalance
    public static func asyncGetBalance(jobId: UInt64) async throws -> BalanceResult {
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: BalanceResult.self)
        return result
    }

    
    // required to get JobId from asyncCall
    public static func asyncOpen(jobId: UInt64) async throws -> WalletResult {
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: WalletResult.self)
        return result
    }

    // required to get JobId from asyncCall
    public static func asyncClose(jobId: UInt64) async throws -> SuccessResult {
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: SuccessResult.self)
        return result
    }
    
    // Currently ZANO always retuns 10000000000(0.01)
//    https://github.com/hyle-team/zano/blob/69a5d42d9908b7168247e103b2b40aae8c1fb3f5/src/currency_core/currency_config.h#L63
//    https://github.com/hyle-team/zano/blob/69a5d42d9908b7168247e103b2b40aae8c1fb3f5/src/wallet/plain_wallet_api.cpp#L677
    public static func getCurrentTxFee(priority: UInt64) -> UInt64 {
        return UInt64(ZanoCore.get_current_tx_fee(priority))
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

