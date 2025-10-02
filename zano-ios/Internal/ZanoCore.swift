//
//  ZanoCore.swift
//  zano-ios
//
//  Created by Jumpei Katayama on 2024/10/11.
//

internal import CxxStdlib
import Foundation
internal import os.lock
internal import wallet

// Copied from https://github.com/hyle-team/zano_native_lib_package_ios/blob/main/Sources/ZanoWallet/ZanoWallet.swift
enum ZanoCore {
    private static let _lock = OSAllocatedUnfairLock()
    @inline(__always)
    private static func withBridge<T>(_ body: () -> T) -> T {
        _lock.withLock { body() }
    }

    @inline(__always) private static func s(_ body: () -> CxxStdlib.std.string)
        -> String
    {
        withBridge { String(body()) }
    }

    static func get_versionCpp() -> String {
        s { plain_wallet.get_version() }
    }

    //        ### Typedef
    //        - `hwallet`<br>A type representing a wallet handle, defined as `int64_t`.
    typealias hwallet = plain_wallet.hwallet

    //            ### Initialization Functions
    static func initAddress(
        _ address: std.string,
        _ working_dir: std.string,
        _ log_level: Int32
    ) -> String {
        s { plain_wallet.`init`(address, working_dir, log_level) }
    }

    static func initIpPort(
        _ ip: std.string,
        _ port: std.string,
        _ working_dir: std.string,
        _ log_level: Int32
    ) -> String {
        s { plain_wallet.`init`(ip, port, working_dir, log_level) }
    }

    //        ### Utility Functions
    static func reset() -> String {
        s { plain_wallet.reset() }
    }

    static func set_log_level(level: Int32 = 0) -> String {
        s { plain_wallet.set_log_level(level) }
    }

    static func get_version() -> String {
        s { plain_wallet.get_version() }
    }

    static func get_wallet_files() -> String {
        s { plain_wallet.get_wallet_files() }
    }

    static func get_export_private_info(_ target_dir: std.string) -> String {
        s { plain_wallet.get_export_private_info(target_dir) }
    }

    static func delete_wallet(_ file_name: std.string) -> String {
        s { plain_wallet.delete_wallet(file_name) }
    }

    static func get_address_info(_ addr: std.string) -> String {
        s { plain_wallet.get_address_info(addr) }
    }

    static func get_appconfig(_ encryption_key: std.string) -> String {
        s { plain_wallet.get_appconfig(encryption_key) }
    }

    static func set_appconfig(
        _ conf_str: std.string,
        _ encryption_key: std.string
    ) -> String {
        s { plain_wallet.set_appconfig(conf_str, encryption_key) }
    }

    static func generate_random_key(_ lenght: UInt64) -> String {
        s { plain_wallet.generate_random_key(lenght) }
    }

    static func get_logs_buffer() -> String {
        s { plain_wallet.get_logs_buffer() }
    }

    static func truncate_log() -> String {
        s { plain_wallet.truncate_log() }
    }

    static func get_connectivity_status() -> String {
        s { plain_wallet.get_connectivity_status() }
    }

    //        ### Wallet Management Functions
    static func open(_ path: std.string, _ password: std.string) -> String {
        s { plain_wallet.open(path, password) }
    }

    static func restore(
        _ seed: std.string,
        _ path: std.string,
        _ password: std.string,
        _ seed_password: std.string
    ) -> String {
        s { plain_wallet.restore(seed, path, password, seed_password) }
    }

    static func generate(_ path: std.string, _ password: std.string) -> String {
        s { plain_wallet.generate(path, password) }
    }

    static func get_opened_wallets() -> String {
        s { plain_wallet.get_opened_wallets() }
    }

    //        ### Wallet Operations
    static func get_wallet_status(_ h: hwallet) -> String {
        s { plain_wallet.get_wallet_status(h) }
    }

    static func close_wallet(_ h: hwallet) -> String {
        s { plain_wallet.close_wallet(h) }
    }

    static func invoke(_ h: hwallet, _ params: std.string) -> String {
        s { plain_wallet.invoke(h, params) }
    }

    //        ### Asynchronous API Functions
    static func async_call(
        _ method_name: std.string,
        _ instance_id: UInt64,
        _ params: std.string
    ) -> String {
        s { plain_wallet.async_call(method_name, instance_id, params) }
    }

    static func try_pull_result(_ uint64_t: UInt64) -> String {
        s { plain_wallet.try_pull_result(uint64_t) }
    }

    static func sync_call(
        _ method_name: std.string,
        _ instance_id: UInt64,
        _ params: std.string
    ) -> String {
        s { plain_wallet.sync_call(method_name, instance_id, params) }
    }

    //        ### Cake Wallet API Extension
    //        bool is_wallet_exist(const std::string& path);
    static func is_wallet_exist(_ path: std.string) -> Bool {
        withBridge { plain_wallet.is_wallet_exist(path) }
    }

    static func get_wallet_info(_ h: hwallet) -> String {
        s { plain_wallet.get_wallet_info(h) }
    }

    static func reset_wallet_password(_ h: hwallet, _ password: std.string)
        -> String
    {
        s { plain_wallet.reset_wallet_password(h, password) }
    }

    static func get_current_tx_fee(_ priority: UInt64) -> CxxStdlib.__uint64_t {
        withBridge { UInt64(plain_wallet.get_current_tx_fee(priority)) }
    }
}
