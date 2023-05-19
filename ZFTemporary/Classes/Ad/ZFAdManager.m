//
//  ZFAdManager.m
//  ZFInterimCode
//
//  Created by admin on 2023/5/19.
//

#import "ZFAdManager.h"

@implementation ZFAdManager

+ (ZFAdManager *)shared {
    
    static ZFAdManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFAdManager alloc] init];
    });
    return manager;
}

@end
