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
    public static func InitIpPort(ip: String, port: String, working_dir: String, log_level:Int32) -> String {
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
        return jsonStr
    }
    
    // MARK: - Utility Functions
    //    close all opened wallets without saving files
//    public static func reset() throws -> SuccessResult {
    public static func reset() -> String {
        debugPrint("\(#function) starts")
        
        let jsonStr = String(ZanoCore.reset())
        return jsonStr
    }
    
    public static func getVersion() -> String {
        debugPrint("\(#function) starts")
        return String(ZanoCore.get_version())
    }

    public static func getWalletNames() -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(ZanoCore.get_wallet_files())
        return jsonStr
    }
    
    public static func deleteWallet(file_name: String) -> String {
        debugPrint("\(#function) starts")
        let fileName = StringConversionUtils.swiftStringToCppString(file_name)
        let jsonStr = String(ZanoCore.delete_wallet(fileName))
        return jsonStr
    }

    public static func getAddressInfo(addr: String) -> String {
        debugPrint("\(#function) starts")
        let address = StringConversionUtils.swiftStringToCppString(addr)
        let jsonStr = String(ZanoCore.get_address_info(address))
        return jsonStr
    }
    
    // MARK: - Configuration Functions
    public static func getLogsBuffer() -> String {
        debugPrint("\(#function) starts")
        return String(ZanoCore.get_logs_buffer())
    }
    
    public static func truncateLog() -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(ZanoCore.truncate_log())
        
        return jsonStr
    }

    public static func getConnectivityStatus() -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(ZanoCore.get_connectivity_status())
        return jsonStr
    }
    
    // MARK: - Wallet Management Functions
    public static func restore(seed: String, walletName: String, password: String, seed_password:String) -> String {
        debugPrint("\(#function) starts")
        let sd = StringConversionUtils.swiftStringToCppString(seed)
        let pa = StringConversionUtils.swiftStringToCppString(walletName)
        let ps = StringConversionUtils.swiftStringToCppString(password)
        let sdps = StringConversionUtils.swiftStringToCppString(seed_password)
        
        
        debugPrint("seed is \(sd)")
        debugPrint("walletName is \(pa)")
        debugPrint("ps is \(ps)")
        debugPrint("sdps is \(sdps)")
        let jsonStr = String(ZanoCore.restore(sd, pa, ps, sdps))
        return jsonStr
    }
    
    // Create a new wallet
    // https://github.com/hyle-team/zano_mobile/blob/6cf344ee1d1b8f462c9339cce5054bc1fd2790b8/src/cpp/zano_wallet_interface_impl.cxx#L74
    // generate_new_wallet
    public static func generate(walletName: String, password: String) -> String {
        debugPrint("\(#function) starts")
        let name = StringConversionUtils.swiftStringToCppString(walletName)
        let ps = StringConversionUtils.swiftStringToCppString(password)
        debugPrint("ps is \(name)")
        debugPrint("sdps is \(ps)")
        
        let jsonStr = String(ZanoCore.generate(name, ps))
        return jsonStr
    }
    
    // response can be "{\r\n  \"id\": 0,\r\n  \"jsonrpc\": \"\"\r\n}"
    public static func getOpenedWallets() -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(ZanoCore.get_opened_wallets())
        return jsonStr
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
    public static func asyncCall(methodName: String, walletId: UInt64, params: String) throws -> String {
        debugPrint("\(#function) starts")
        guard asyncCallMethods.contains(methodName) else {
            throw ZANOError.unknown(message: "unsupported method name")
        }
        
        let name = StringConversionUtils.swiftStringToCppString(methodName)
        let param = StringConversionUtils.swiftStringToCppString(params)
        
        debugPrint("------")
        debugPrint(name)
        debugPrint(walletId)
        debugPrint(param)
        
        let jsonStr = String(ZanoCore.async_call(name, walletId, param))
        return jsonStr
    }
    
    // MARK:  Wallet Operations
    public static func asyncGetRestoreInfo(jobId: UInt64) async  -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        return jsonStr
    }
    
    
    // MARK:  Wallet Operations
    public static func asyncGetWalletStatus(jobId: UInt64) async -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        return jsonStr
    }

    
    public static func asyncRestore(jobId: UInt64) async -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        return jsonStr
    }
    
    // https://docs.zano.org/docs/build/rpc-api/wallet-rpc-api/getbalance
    public static func asyncGetBalance(jobId: UInt64) async -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        return jsonStr
    }

    
    // required to get JobId from asyncCall
    // response can be "{\"status\": \"idle\"}"
    public static func asyncOpen(jobId: UInt64) async -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(ZanoCore.try_pull_result(jobId))
        debugPrint("jsonStr")
        debugPrint(jsonStr)
        debugPrint("=======")
        
        return jsonStr
    }

    public static func asyncClose(jobId: UInt64) async throws -> String {
        debugPrint("\(#function) starts")
        let jsonStr = String(String(ZanoCore.try_pull_result(jobId)))
        return jsonStr
    }
    
    // Currently ZANO always retuns 10000000000(0.01)
//    https://github.com/hyle-team/zano/blob/69a5d42d9908b7168247e103b2b40aae8c1fb3f5/src/currency_core/currency_config.h#L63
//    https://github.com/hyle-team/zano/blob/69a5d42d9908b7168247e103b2b40aae8c1fb3f5/src/wallet/plain_wallet_api.cpp#L677
    public static func getCurrentTxFee(priority: UInt64) -> UInt64 {
        return UInt64(ZanoCore.get_current_tx_fee(priority))
    }
}

public enum ZANOError: Error {
    case errorResponse(code: String, message: String)
    case asyncErrorResponse(status: String, code: String, message: String)
    case unknown(message: String)
    case conversionFailure(message: String)
}

