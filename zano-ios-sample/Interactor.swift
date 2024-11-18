//
//  Interactor.swift
//  zano-ios-sample
//
//  Created by Jumpei Katayama on 2024/11/18.
//

import Foundation
import zano_ios


class Interactor {
    var walletAndID: [String: Int] = [:]
    let pollDelay: UInt64 = 1_000_000_000 // in nanoseconds (1 second)
    let timeout: UInt64 = 5_000_000_000    // in nanoseconds (5 seconds)

    public static var shared: Interactor = Interactor()
    var initStatus: String = ""
    var ip: String = "\(ZANOConst.ZANO_MAINNET_IP):\(ZANOConst.ZANO_MAINNET_PORT)"
    var workingDir: String = ""
    
    func initZano() -> String {
        let fileManager = FileManager.default
        if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let strX = docsDir.path
            
            Interactor.shared.workingDir = strX
            let res = try! ZanoService.shared.initIpPort(ip: ZANOConst.ZANO_MAINNET_IP, port: ZANOConst.ZANO_MAINNET_PORT, working_dir: strX, log_level: 0)
            self.initStatus = res.returnCode
            
            
            return res.returnCode
        } else {
            return "Error"
        }
    }
    
    func getConnectivityStatus() async throws -> ConnectivityStatus {
        return try ZanoService.shared.getConnectivityStatus()
    }
    
    func getVersion() -> String {
        return ZanoService.getVersion()
    }
    
    func getTransactionFee() -> String {
        return ZanoService.getCurrentTxFee(priority: 0).description
    }

    func createWallet(name: String, pass: String) throws -> WalletResult {
        guard name.count > 0 else {
            debugPrint("should be name.count > 0, pass.count > ")
            throw ZANOError.unknown(message: "")
        }
        if let res = try? ZanoService.shared.generate(walletName: name, password: pass) {
            walletAndID[name] = res.walletID
            debugPrint(res)
            return res
        } else {
            throw ZANOError.unknown(message: "ZanoService.shared.generate failed")
        }
    }
    
    public func getWalletNames() -> [String] {
        do {
            return try ZanoService.shared.getWalletNames().items
        } catch {
            debugPrint("ZanoService.shared.getWalletNames().items throws \(error.localizedDescription)")
            return []
        }
    }
    
    func getOpenedWallets() async -> [WalletResult] {
        do {
            return try ZanoService.shared.getOpenedWallets()
        } catch {
            debugPrint("getOpenedWallets throws \(error.localizedDescription)")
            return []
        }
    }
    
    
    
    public func reset() throws -> SuccessResult {
        return try ZanoService.shared.reset()
    }
    func asyncRestore(name: String, seed: String, password: String, seedPass: String) async throws -> WalletResult? {
        let params: [String: Any] = [
            "seed_phrase": seed,
            "path": name,
            "pass": password,
            "seed_pass": seedPass,
        ]

        guard let jsonString = JsonConverter.dictonaryToJsonString(dic: params) else {
            throw ZANOError.unknown(message: "Pram is invalid")
        }

        do {
            let startTimer = DispatchTime.now()

            let result = try await ZanoService.shared.asyncCall(methodName: "restore", walletId: 0, params: jsonString)
            
            var status: AsyncSatus = .idle
            
            debugPrint("waiting for 100_000_000 nano sec")
            try await Task.sleep(nanoseconds: 100_000_000)
            while DispatchTime.now().uptimeNanoseconds - startTimer.uptimeNanoseconds < timeout {
                debugPrint("DispatchTime.now().uptimeNanoseconds - startTimer.uptimeNanoseconds < timeout is true")
                let result1 = try await ZanoService.shared.asyncOpen(jobId: result.jobId)
                
                print("async response \(result1)")
                status = result1.status
                
                switch result1.status {
                case .canceled:
                    debugPrint("canceled...")
                    return nil
                case .delivered:
                    debugPrint("delivered...")
                    return result1.walletResult
                case .idle:
                    // Continue polling
                    debugPrint("idle...")
                    break
                @unknown default:
                    return nil
                }
                debugPrint("status is \(status)")
                debugPrint("pollDelay... \(pollDelay)")
                try await Task.sleep(nanoseconds: pollDelay)
            }
            
            debugPrint("DispatchTime.now().uptimeNanoseconds - startTimer.uptimeNanoseconds < timeout is false")
            return nil
        } catch {
            debugPrint("asyncOpen() throws error")
            debugPrint(error.localizedDescription)
            throw ZANOError.unknown(message: "error.localizedDescription")
        }

    }
    
    
    
    func asyncOpen(name: String, pass: String) async throws -> WalletResult? {
        let param = "{\"path\": \"\(name)\", \"pass\": \"\(pass)\"}"
        do {
            let startTimer = DispatchTime.now()

            let result = try await ZanoService.shared.asyncCall(methodName: "open", walletId: 0, params: param)
            
            var status: AsyncSatus = .idle
            
            debugPrint("waiting for 100_000_000 nano sec")
            try await Task.sleep(nanoseconds: 100_000_000)
            while DispatchTime.now().uptimeNanoseconds - startTimer.uptimeNanoseconds < timeout {
                debugPrint("DispatchTime.now().uptimeNanoseconds - startTimer.uptimeNanoseconds < timeout is true")
                let result1 = try await ZanoService.shared.asyncOpen(jobId: result.jobId)
                
                print("async response \(result1)")
                status = result1.status
                
                switch result1.status {
                case .canceled:
                    debugPrint("canceled...")
                    return nil
                case .delivered:
                    debugPrint("delivered...")
                    return result1.walletResult
                case .idle:
                    // Continue polling
                    debugPrint("idle...")
                    break
                @unknown default:
                    return nil
                }
                debugPrint("status is \(status)")
                debugPrint("pollDelay... \(pollDelay)")

                try await Task.sleep(nanoseconds: pollDelay)
            }
            debugPrint("ZanoService.shared.asyncCall")
            debugPrint(result)
            debugPrint("ZanoService.shared.asyncCall end")
            return nil
        } catch {
            debugPrint("asyncOpen() throws error")
            debugPrint(error.localizedDescription)
            throw ZANOError.unknown(message: "error.localizedDescription")
        }
    }
}
