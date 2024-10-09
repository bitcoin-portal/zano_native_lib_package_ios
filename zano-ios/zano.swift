//
//  zano.swift
//  zano-ios
//
//  Created by Jumpei Katayama on 2024/09/13.
//

import Foundation
internal import CxxStdlib
internal import wallet


public typealias ZANOString = UnsafeRawPointer

func convertUnsafeRawPointerToStdString(rawPointer: UnsafeRawPointer) -> CxxStdlib.std.string {
    let cStringPointer = rawPointer.assumingMemoryBound(to: CChar.self)
    let swiftString = String(cString: cStringPointer)
    return CxxStdlib.std.string(swiftString)
}

public func swiftStringToStdString(with string: String) -> UnsafeRawPointer {
    let cString = string.cString(using: .utf8)!
    let rawPointer = UnsafeRawPointer(cString.withUnsafeBufferPointer {
        $0.baseAddress!
    })
    return rawPointer
}

public enum ZanoWallet {
    //        ### Typedef
    //        - `hwallet`<br>A type representing a wallet handle, defined as `int64_t`.
//    public typealias hwallet = plain_wallet.hwallet
//    
    //            ### Initialization Functions
    //            std::string init(const std::string& address, const std::string& working_dir, int log_level);
    public static func testInitAddress(_ address: String, _ working_dir: String, _ log_level: Int32) -> String {
        let addr = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: address))
        let workingDirRaw = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: working_dir))

        return String(plain_wallet.`init`(addr, workingDirRaw, log_level))
    }
//    
    //        std::string init(const std::string& ip, const std::string& port, const std::string& working_dir, intlog_level);
    public static func InitIpPort(_ ip: String, _ port: String, _ working_dir: String, _ log_level:Int32) -> String {
        let ipRaw = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: ip))
        let portRaw = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: port))
        let workingDirRaw = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: working_dir))
        return String(plain_wallet.`init`(ipRaw, portRaw, workingDirRaw, log_level))
    }
    
    // MARK: - Utility Functions
    public static func reset() -> String {
        return String(plain_wallet.reset())
    }
    
    public static func set_log_level() -> String {
        return String(plain_wallet.set_log_level(0))
    }
    
    //        std::string get_version();
    public static func get_version() -> String {
        String(plain_wallet.get_version())
    }
    
    //        std::string get_wallet_files();
    public static func get_wallet_files() -> String {
        String(plain_wallet.get_wallet_files())
    }
//    
//            std::string get_export_private_info(const std::string& target_dir);
    public static func get_export_private_info(_ target_dir: String) -> String {
        let dir = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: target_dir))
        return String(plain_wallet.get_export_private_info(dir))
    }
    
    //        std::string delete_wallet(const std::string& file_name);
    public static func delete_wallet(_ file_name: String) -> String {
        let fileName = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: file_name))
        return String(plain_wallet.delete_wallet(fileName))
    }
//    
    //        std::string get_address_info(const std::string& addr);
    public static func get_address_info(_ addr: String) -> String {
        let address = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: addr))
        return String(plain_wallet.get_address_info(address))
    }

    // MARK: - Configuration Functions
    
    public static func get_appconfig(_ encryption_key: String) -> String {
        let key = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: encryption_key))
        return String(plain_wallet.get_appconfig(key))
    }
    
    public static func set_appconfig(_ conf_str: String, _ encryption_key: String) -> String {
        let conf = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: conf_str))
        let key = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: encryption_key))

        return String(plain_wallet.set_appconfig(conf, key))
    }
    
    public static func generate_random_key(_ lenght: UInt64) -> String {
        return String(plain_wallet.generate_random_key(lenght))
    }
    
    public static func get_logs_buffer() -> String {
        String(plain_wallet.get_logs_buffer())
    }

    public static func truncate_log() -> String {
        String(plain_wallet.truncate_log())
    }

    public static func get_connectivity_status() -> String {
        String(plain_wallet.get_connectivity_status())
    }

    // MARK: - Wallet Management Functions
    public static func open(_ path: String, _ password: String) -> String {
        let pa = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: path))
        let ps = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: password))

        return String(plain_wallet.open(pa, ps))
    }
    
    public static func restore(_ seed: String, _ path: String, _ password: String, _ seed_password:String) -> String {
        let sd = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: seed))
        let pa = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: path))
        let ps = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: password))
        let sdps = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: seed_password))

        return String(plain_wallet.restore(sd, pa, ps, sdps))
    }
    
    public static func generate(_ path: String, _ password: String) -> String {
        let pa = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: path))
        let ps = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: password))

        return String(plain_wallet.generate(pa, ps))
    }

    public static func get_opened_wallets() -> String {
        return String(plain_wallet.get_opened_wallets())
    }
//    
    // MARK: - Wallet Operations
    //        std::string get_wallet_status(hwallet h);
//    public static func get_wallet_status(_ h: hwallet) -> CxxStdlib.std.string {
//        plain_wallet.get_wallet_status(h)
//    }
////    
//    //        std::string close_wallet(hwallet h);
//    public static func close_wallet(_ h: hwallet) -> CxxStdlib.std.string {
//        plain_wallet.close_wallet(h)
//    }
////    
//    //        std::string invoke(hwallet h, const std::string& params);
//    public static func invoke(_ h: hwallet, _ params: std.string) -> CxxStdlib.std.string {
//        plain_wallet.invoke(h, params)
//    }
//    
//    
    // MARK: - Asynchronous API Functions
    public static func async_call(_ method_name: String, _ instance_id: UInt64, _ params: String) ->String {
        let name = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: method_name))
        let param = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: params))

        return String(plain_wallet.async_call(name, instance_id, param))
    }
    
    public static func try_pull_result(_ uint64_t: UInt64) -> String {
        return String(plain_wallet.try_pull_result(uint64_t))
    }
    
    public static func sync_call(_ method_name: String, _ instance_id: UInt64, _ params: String) ->String {
        let method = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: method_name))
        let param = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: params))

        return String(plain_wallet.sync_call(method, instance_id, param))
    }
    
    // MARK: - Cake Wallet API Extension
    public static func is_wallet_exist(_ path: String) -> Bool {
        let ps = convertUnsafeRawPointerToStdString(rawPointer: swiftStringToStdString(with: path))

        return plain_wallet.is_wallet_exist(ps)
    }
    
    //        std::string get_wallet_info(hwallet h);
//    public static func get_wallet_info(_ h: hwallet) -> CxxStdlib.std.string {
//        plain_wallet.get_wallet_info(h)
//    }
    
    //        std::string reset_wallet_password(hwallet h, const std::string& password);
//    public static func reset_wallet_password(_ h: hwallet, _ password: std.string) -> CxxStdlib.std.string {
//        plain_wallet.reset_wallet_password(h, password)
//    }
    
    //        uint64_t get_current_tx_fee(uint64_t priority); // 0 (default), 1 (unimportant), 2 (normal), 3 (elevated),4 (priority)
    public static func get_current_tx_fee(_ priority: UInt64) -> UInt64 {
        return UInt64(plain_wallet.get_current_tx_fee(priority))
    }
}
