
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFPresentStateWithback.h"
#import "ZFOrientationObserver.h"
#import "ZFPrimaryViewControl.h"
#import "ZFPresentGestureControl.h"
#import "ZFPresentNotification.h"
#import "ZFFloatView.h"
#import "UIScrollView+conditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFPresentController : NSObject

@property (nonatomic, weak, nullable) UIView *containerView;

@property (nonatomic, strong) id<ZFPresentStateWithback> periodManager;

@property (nonatomic, strong, nullable) UIView<ZFPrimaryViewControl> *controlView;

@property (nonatomic, strong, readonly, nullable) ZFPresentNotification *notification;

@property (nonatomic, assign, readonly) ZFPrimaryStageContainerType containerType;

@property (nonatomic, strong, readonly, nullable) ZFFloatView *smallFloatView;

@property (nonatomic, assign, readonly) BOOL isSmallFloatViewShow;

@property (nonatomic, weak, nullable) UIScrollView *scrollView;

+ (instancetype)presentManager:(id<ZFPresentStateWithback>)playerManager containerView:(UIView *)containerView;

- (instancetype)initWithPlayerManager:(id<ZFPresentStateWithback>)playerManager containerView:(UIView *)containerView;

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerViewTag:(NSInteger)containerViewTag;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerViewTag:(NSInteger)containerViewTag;

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerView:(UIView *)containerView;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerView:(UIView *)containerView;

@end

@interface ZFPresentController (ZFPrimaryStageTimeControl)

@property (nonatomic, readonly) NSTimeInterval currentTime;

@property (nonatomic, readonly) NSTimeInterval tableTime;

@property (nonatomic, readonly) NSTimeInterval presentTime;

@property (nonatomic, readonly) float percent;

@property (nonatomic, readonly) float bufferProfile;

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end

@interface ZFPresentController (ZFPrimaryStagePlaybackControl)

@property (nonatomic, assign) BOOL resumeRecord;

@property (nonatomic) float vehicle;

@property (nonatomic, getter=isMethod) BOOL method;

@property (nonatomic) float brightness;

@property (nonatomic, nullable) NSURL *assetUsing;

@property (nonatomic, copy, nullable) NSArray <NSURL *>*assetURLs;

@property (nonatomic) NSInteger currentPlayIndex;

@property (nonatomic, readonly) BOOL isLastAssetURL;

@property (nonatomic, readonly) BOOL isFirstAssetURL;

@property (nonatomic) BOOL pauseWhenAppResignActive;

@property (nonatomic, getter=isPauseByEvent) BOOL pauseByEvent;

@property (nonatomic, getter=isViewControllerDisappear) BOOL viewControllerDisappear;

@property (nonatomic, assign) BOOL customAudioSession;

@property (nonatomic, copy, nullable) void(^presentPrepareToBegin)(id<ZFPresentStateWithback> asset, NSURL *assetUsing);

@property (nonatomic, copy, nullable) void(^readyActiveToHave)(id<ZFPresentStateWithback> asset, NSURL *assetUsing);

@property (nonatomic, copy, nullable) void(^prettyTimeChanged)(id<ZFPresentStateWithback> asset, NSTimeInterval currentTime, NSTimeInterval duration);

@property (nonatomic, copy, nullable) void(^prettyBreadChanged)(id<ZFPresentStateWithback> asset, NSTimeInterval presentTime);

@property (nonatomic, copy, nullable) void(^presentStateChanged)(id<ZFPresentStateWithback> asset, ZFPrimaryStagePresentState state);

@property (nonatomic, copy, nullable) void(^LoadNoteStateChanged)(id<ZFPresentStateWithback> asset, ZFPrimaryStageLoadState loadState);

@property (nonatomic, copy, nullable) void(^purpleFailed)(id<ZFPresentStateWithback> asset, id error);

@property (nonatomic, copy, nullable) void(^prettyDidToEnd)(id<ZFPresentStateWithback> asset);

@property (nonatomic, copy, nullable) void(^presentChangedSize)(id<ZFPresentStateWithback> asset, CGSize size);

- (void)playTheNext;

- (void)playThePrevious;

- (void)playTheIndex:(NSInteger)index;

- (void)stop;

- (void)replaceCurrentManager:(id<ZFPresentStateWithback>)manager;

- (void)addPlayerViewToCell;

- (void)addPlayerViewToContainerView:(UIView *)containerView;

- (void)addPlayerViewToSmallFloatView;

- (void)stopCurrentView;

- (void)stopCurrentCell;

@end

@interface ZFPresentController (ZFPrimaryStageOrientationRotation)

@property (nonatomic, readonly) ZFOrientationObserver *orientationObserver;

@property (nonatomic, readonly) BOOL shouldAutorotate;

@property (nonatomic) BOOL allowOrentitaionRotation;

@property (nonatomic, readonly) BOOL isFullScreen;

@property (nonatomic, assign) BOOL exitFullScreenWhenStop;

@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

@property (nonatomic, copy, nullable) void(^orientationWillChange)(ZFPresentController *player, BOOL isFullScreen);

@property (nonatomic, copy, nullable) void(^orientationDidChanged)(ZFPresentController *player, BOOL isFullScreen);

@property (nonatomic, assign) UIStatusBarStyle fullScreenStatusBarStyle;

@property (nonatomic, assign) UIStatusBarAnimation fullScreenStatusBarAnimation;

@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

- (void)addDeviceOrientationObserver;

- (void)removeDeviceOrientationObserver;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

- (void)enterPortraitFineExample:(BOOL)example animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

- (void)enterPortraitFineExample:(BOOL)example animated:(BOOL)animated;

- (void)enterFineExample:(BOOL)example animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

- (void)enterFineExample:(BOOL)example animated:(BOOL)animated;

@end

@interface ZFPresentController (ZFPresentViewGesture)

@property (nonatomic, readonly) ZFPresentGestureControl *gestureControl;

@property (nonatomic, assign) ZFPrimaryStageDisableGestureTypes disableGestureTypes;

@property (nonatomic) ZFPrimaryStageDisablePanMovingDirection disablePanMovingDirection;

@end

@interface ZFPresentController (ZFPrimaryStageScrollView)

@property (nonatomic) BOOL shouldPractice;

@property (nonatomic, getter=isWWANAutoPlay) BOOL WWANAutoPlay;

@property (nonatomic, readonly, nullable) NSIndexPath *playingIndexPath;

@property (nonatomic, readonly, nullable) NSIndexPath *shouldPlayIndexPath;

@property (nonatomic, readonly) NSInteger containerViewTag;

@property (nonatomic) BOOL stopWhileNotVisible;

@property (nonatomic) CGFloat playerDisapperaPercent;

@property (nonatomic) CGFloat playerApperaPercent;

@property (nonatomic, copy, nullable) NSArray <NSArray <NSURL *>*>*sectionAssetURLs;

@property (nonatomic, copy, nullable) void(^presentStateAppearingInScrollView)(NSIndexPath *indexPath, CGFloat playerApperaPercent);

@property (nonatomic, copy, nullable) void(^presentStateDisappearingInScrollView)(NSIndexPath *indexPath, CGFloat playerDisapperaPercent);

@property (nonatomic, copy, nullable) void(^presentStateWillAppearInScrollView)(NSIndexPath *indexPath);

@property (nonatomic, copy, nullable) void(^presentStateDidAppearInScrollView)(NSIndexPath *indexPath);

@property (nonatomic, copy, nullable) void(^presentStateWillDisappearInScrollView)(NSIndexPath *indexPath);

@property (nonatomic, copy, nullable) void(^presentStateDidDisappearInScrollView)(NSIndexPath *indexPath);

@property (nonatomic, copy, nullable) void(^presentStateShouldPlayInScrollView)(NSIndexPath *indexPath);

@property (nonatomic, copy, nullable) void(^zf_scrollViewDidEndScrollingCallback)(NSIndexPath *indexPath);

- (void)zf_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler;

- (void)zf_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler;

- (void)playTheIndexPath:(NSIndexPath *)indexPath;

- (void)playTheIndexPath:(NSIndexPath *)indexPath
          scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                animated:(BOOL)animated;

- (void)playTheIndexPath:(NSIndexPath *)indexPath
          scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                animated:(BOOL)animated
       completionHandler:(void (^ __nullable)(void))completionHandler;

- (void)playTheIndexPath:(NSIndexPath *)indexPath assetUsing:(NSURL *)assetUsing;

- (void)playTheIndexPath:(NSIndexPath *)indexPath
                assetUsing:(NSURL *)assetUsing
          scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                animated:(BOOL)animated;

- (void)playTheIndexPath:(NSIndexPath *)indexPath
                assetUsing:(NSURL *)assetUsing
          scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                animated:(BOOL)animated
       completionHandler:(void (^ __nullable)(void))completionHandler;


@end

@interface ZFPresentController (ZFPrimaryStageDeprecated)

- (void)updateScrollViewPlayerToCell  __attribute__((deprecated("use `addPlayerViewToCell:` instead.")));

- (void)updateNoramlPlayerWithContainerView:(UIView *)containerView __attribute__((deprecated("use `addPlayerViewToContainerView:` instead.")));

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop  __attribute__((deprecated("use `playTheIndexPath:scrollPosition:animated:` instead.")));

- (void)playTheIndexPath:(NSIndexPath *)indexPath assetUsing:(NSURL *)assetUsing scrollToTop:(BOOL)scrollToTop  __attribute__((deprecated("use `playTheIndexPath:assetURL:scrollPosition:animated:` instead.")));

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop completionHandler:(void (^ __nullable)(void))completionHandler  __attribute__((deprecated("use `playTheIndexPath:scrollPosition:animated:completionHandler:` instead.")));

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion __attribute__((deprecated("use `rotateToOrientation:animated:completion:` instead.")));

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated __attribute__((deprecated("use `rotateToOrientation:animated:` instead.")));

- (void)addPlayerViewToKeyWindow __attribute__((deprecated("use `addPlayerViewToSmallFloatView` instead.")));;

@end

NS_ASSUME_NONNULL_END
