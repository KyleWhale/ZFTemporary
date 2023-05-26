

#import <Foundation/Foundation.h>
#import "ZFPresentView.h"
#import "ZFPrimaryConst.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZFPresentStateWithback <NSObject>

@required

@property (nonatomic) ZFPresentView *view;

@property (nonatomic) float vehicle;

@property (nonatomic, getter=isMethod) BOOL method;

@property (nonatomic) float resultRest;

@property (nonatomic, readonly) NSTimeInterval currentTime;

@property (nonatomic, readonly) NSTimeInterval tableTime;

@property (nonatomic, readonly) NSTimeInterval presentTime;

@property (nonatomic) NSTimeInterval sleepTime;

@property (nonatomic, readonly) BOOL isPleasure;

@property (nonatomic) ZFPrimaryStageScalingMode scalingMode;

@property (nonatomic, readonly) BOOL isPreparedToPlace;

@property (nonatomic) BOOL shouldPractice;

@property (nonatomic, nullable) NSURL *assetUsing;

@property (nonatomic) CGSize verySize;

@property (nonatomic, readonly) ZFPrimaryStagePresentState state;

@property (nonatomic, readonly) ZFPrimaryStageLoadState loadState;

@property (nonatomic, copy, nullable) void(^presentPrepareToBegin)(id<ZFPresentStateWithback> asset, NSURL *assetUsing);

@property (nonatomic, copy, nullable) void(^readyActiveToHave)(id<ZFPresentStateWithback> asset, NSURL *assetUsing);

@property (nonatomic, copy, nullable) void(^prettyTimeChanged)(id<ZFPresentStateWithback> asset, NSTimeInterval currentTime, NSTimeInterval duration);

@property (nonatomic, copy, nullable) void(^prettyBreadChanged)(id<ZFPresentStateWithback> asset, NSTimeInterval presentTime);

@property (nonatomic, copy, nullable) void(^presentStateChanged)(id<ZFPresentStateWithback> asset, ZFPrimaryStagePresentState state);

@property (nonatomic, copy, nullable) void(^LoadNoteStateChanged)(id<ZFPresentStateWithback> asset, ZFPrimaryStageLoadState loadState);

@property (nonatomic, copy, nullable) void(^purpleFailed)(id<ZFPresentStateWithback> asset, id error);

@property (nonatomic, copy, nullable) void(^prettyDidToEnd)(id<ZFPresentStateWithback> asset);

@property (nonatomic, copy, nullable) void(^presentChangedSize)(id<ZFPresentStateWithback> asset, CGSize size);

- (void)prepareToPlay;

- (void)reloadPresent;

- (void)play;

- (void)pause;

- (void)replay;

- (void)stop;

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@optional

- (UIImage *)thumbnailImageAtCurrentTime;

- (void)thumbnailImageAtCurrentTime:(void(^)(UIImage *))handler;

@end

NS_ASSUME_NONNULL_END
