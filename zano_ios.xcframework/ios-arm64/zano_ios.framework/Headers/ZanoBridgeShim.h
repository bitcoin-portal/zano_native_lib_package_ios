//
//  ZanoString.h
//  zano-ios
//
//  Created by Jumpei Katayama on 2024/10/09.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

FOUNDATION_EXPORT NSString * ZanoAsyncCallShim(NSString *methodName,
                                               uint64_t walletId,
                                               NSString *params);
FOUNDATION_EXPORT NSData * ZanoTryPullResultDataShim(uint64_t jobId);

#ifdef __cplusplus
} // extern "C"
#endif
NS_ASSUME_NONNULL_END
