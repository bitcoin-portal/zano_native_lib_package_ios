//
//  ZanoString.m
//  zano-ios
//
//  Created by Jumpei Katayama on 2024/10/09.
//

#import <Foundation/Foundation.h>
#import <plain_wallet_api.h> 
#include <string>
#include <exception>
#import "ZanoBridgeShim.h"

using std::string;

static inline string toStd(NSString *s) {
    if (!s) return {};
    const char *p = [s UTF8String];
    return p ? string(p) : string();
}

static inline NSString * fromStd(const string &s) {
    return [[NSString alloc] initWithBytes:s.data() length:s.size()
                                  encoding:NSUTF8StringEncoding];
}

static inline NSString *makeErrorJson(const char *cmsg) {
    NSString *msg = cmsg ? [NSString stringWithUTF8String:cmsg] : @"unknown";
    if (!msg) msg = @"unknown";
    NSDictionary *obj = @{ @"status": @"error",
                           @"code": @"exception",
                           @"message": msg };
    NSData *d = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    return [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}

extern "C" NSString * ZanoAsyncCallShim(NSString *methodName, uint64_t walletId, NSString *params) {
    try {
        auto r = plain_wallet::async_call(toStd(methodName), walletId, toStd(params));
        return fromStd(r);
    } catch (const std::exception &e) {
        return makeErrorJson(e.what());
    } catch (...) {
        return makeErrorJson("unknown");
    }
}


NSData * ZanoTryPullResultDataShim(uint64_t jobId) {
    std::string r = plain_wallet::try_pull_result(jobId);
    return [NSData dataWithBytes:r.data() length:r.size()];
}
