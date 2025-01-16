//
//  ZanoService.swift
//  zano-ios-sample
//
//  Created by Jumpei Katayama on 2024/11/18.
//

import Foundation
import zano_ios

class ZanoService {
    
    public static var shared: ZanoService = ZanoService()
    
    public func initIpPort(ip: String, port: String, working_dir: String, log_level:Int32) throws -> SuccessResult {
        
        let result = ZanoWallet.InitIpPort(ip: ip, port: port, working_dir: working_dir, log_level: log_level)
        
        guard let jsonData = result.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        return try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: SuccessResult.self)
    }
    
    public func reset() throws -> SuccessResult {
        let result = ZanoWallet.reset()
        guard let jsonData = result.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        return try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: SuccessResult.self)
    }
    
    func deleteWallet(file_name: String) throws -> SuccessResult {
        let jsonStr = ZanoWallet.deleteWallet(file_name: file_name)
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        return try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: SuccessResult.self)
    }
    
    
    public static func getAddressInfo(addr: String) throws -> AddressInfo {
        let jsonStr = ZanoWallet.getAddressInfo(addr: addr)
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: AddressInfo.self)
        return result
    }
    
    
    public func getConnectivityStatus() throws -> ConnectivityStatus {
        let jsonStr = ZanoWallet.getConnectivityStatus()
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: ConnectivityStatus.self)
        return result
    }
    
    public static func restore(seed: String, walletName: String, password: String, seed_password:String) throws -> WalletResult {
        
        let jsonStr = ZanoWallet.restore(seed: seed, walletName: walletName, password: password, seed_password: seed_password)
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: WalletResult.self)
        
        return result
    }
    
    public func generate(walletName: String, password: String) throws -> WalletResult {
        
        let jsonStr = ZanoWallet.generate(walletName: walletName, password: password)
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        debugPrint("jsonStr is \(jsonStr)")
        
        
        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: WalletResult.self)
        return result
    }
    
    public func getWalletNames() throws -> GetWalletFileResult {
        debugPrint("\(#function) starts")
        let jsonStr = String(ZanoWallet.getWalletNames())

        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }

        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: GetWalletFileResult.self)
        return result
    }
    
    public func getOpenedWallets() throws -> [WalletResult] {
        let jsonStr = ZanoWallet.getOpenedWallets()
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        debugPrint("jsonStr is \(jsonStr)")

        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: [WalletResult].self)
        return result

    }

    
    public func asyncCall(methodName: String, walletId: UInt64, params: String) async throws -> JobResult {
        
        
        let jsonStr = try ZanoWallet.asyncCall(methodName: methodName, walletId: walletId, params: params)
        
        debugPrint(jsonStr)
        debugPrint("------")
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }
        
        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: JobResult.self)
        return result
    }
    
    
    public func asyncGetRestoreInfo(jobId: UInt64) async throws -> WalletSyncStatus {
        let jsonStr = await ZanoWallet.asyncGetRestoreInfo(jobId: jobId)
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }

        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: WalletSyncStatus.self)
        return result

    }
    
    
    public func asyncGetWalletStatus(jobId: UInt64) async throws -> WalletSyncStatus {
        
        let jsonStr = await ZanoWallet.asyncGetWalletStatus(jobId: jobId)

        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }

        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: WalletSyncStatus.self)
        return result

    }
    
    public func asyncRestore(jobId: UInt64) async throws -> WalletResult {
        let jsonStr = await ZanoWallet.asyncRestore(jobId: jobId)
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }

        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: WalletResult.self)
        return result
    }
    
    
    public func asyncGetBalance(jobId: UInt64) async throws -> BalanceResult {
        let jsonStr = await ZanoWallet.asyncRestore(jobId: jobId)

        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }

        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: BalanceResult.self)
        return result
        
    }
    
    public func asyncTransfer(jobId: UInt64) async throws -> TransferResponse {
        let jsonStr = await ZanoWallet.asyncTransfer(jobId: jobId)

        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }

        let result = try JSONRPCParser.parseResponse(jsonData: jsonData, resultType: TransferResponse.self)
        return result
    }
    
    public func asyncOpen(jobId: UInt64) async throws -> AsyncOpenSuccessResponse {
        let jsonStr = await ZanoWallet.asyncOpen(jobId: jobId)
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }

        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: AsyncResult.self)

        debugPrint("try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: AsyncResult.self returns ")
        debugPrint("\(result)")
        let result1 = try AsyncOpenSuccessResponse.create(asyncResult: result)
        debugPrint("result1.walletResult is ")
        debugPrint("\(String(describing: result1.walletResult))")
        return result1
    }
    
    public func asyncClose(jobId: UInt64) async throws -> SuccessResult {
        let jsonStr = try await ZanoWallet.asyncClose(jobId: jobId)

        
        
        guard let jsonData = jsonStr.data(using: .utf8) else {
            throw ZANOError.conversionFailure(message: "")
        }


        let result = try JSONRPCParser.parseJsonResponse(jsonData: jsonData, resultType: SuccessResult.self)
        return result
    }

    
    public static func getCurrentTxFee(priority: UInt64) -> UInt64 {
        return ZanoWallet.getCurrentTxFee(priority: priority)
    }
    
    static func getVersion() -> String {
        return ZanoWallet.getVersion()
    }
    
}


