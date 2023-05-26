//
//  ZFAdManager.h
//  ZFInterimCode
//
//  Created by admin on 2023/5/19.
//

#import <Foundation/Foundation.h>
#import "ZFAdModelProtocol.h"
#import "ZFAdView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFAdManager : NSObject

+ (ZFAdManager *)shared;

@property (nonatomic, strong) id <ZFAdModelProtocol> ad;

@property (nonatomic, strong) ZFAdView *bannerView;

@end

NS_ASSUME_NONNULL_END
