
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if __has_include(<ZFPrimaryStage/ZFPresentStateWithback.h>)
#import <ZFPrimaryStage/ZFPresentStateWithback.h>
#else
#import "ZFPresentStateWithback.h"
#endif

@interface ZFPresentActionManager : NSObject <ZFPresentStateWithback>
@property (nonatomic, assign) BOOL tempPause;
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *primaryStageItem;
@property (nonatomic, strong, readonly) AVPlayer *primaryStage;
@property (nonatomic, assign) NSTimeInterval timeRefreshInterval;
@property (nonatomic, strong) NSDictionary *requestHeader;

@property (nonatomic, strong, readonly) AVPlayerLayer *primaryStageLayer;

@end
