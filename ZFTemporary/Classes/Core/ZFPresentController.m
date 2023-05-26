

#import "ZFPresentController.h"
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIScrollView+conditions.h"
#import "ZFReachabilityManager.h"
#import "ZFPrimaryConst.h"

static NSMutableDictionary <NSString* ,NSNumber *> *_zfPlayRecords;

@interface ZFPresentController ()

@property (nonatomic, strong) ZFPresentNotification *notification;
@property (nonatomic, strong) UISlider *vehicleSlider;
@property (nonatomic, assign) NSInteger containerViewTag;
@property (nonatomic, assign) ZFPrimaryStageContainerType containerType;
@property (nonatomic, strong) ZFFloatView *smallFloatView;
@property (nonatomic, assign) BOOL isSmallFloatViewShow;
@property (nonatomic, nullable) NSIndexPath *playingIndexPath;

@end

@implementation ZFPresentController

@dynamic containerViewTag;
@dynamic playingIndexPath;

- (instancetype)init {
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _zfPlayRecords = @{}.mutableCopy;
        });
        @zf_weakify(self)
        [[ZFReachabilityManager sharedManager] startMonitoring];
        [[ZFReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(ZFReachabilityStatus status) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(veryPractice:reachabilityChanged:)]) {
                [self.controlView veryPractice:self reachabilityChanged:status];
            }
        }];
        [self configureVehicle];
    }
    return self;
}

- (void)configureVehicle {
    MPVolumeView *superView = [[MPVolumeView alloc] init];
    self.vehicleSlider = nil;
    for (UIView *view in [superView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.vehicleSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)dealloc {
    [self.periodManager stop];
}

+ (instancetype)presentManager:(id<ZFPresentStateWithback>)playerManager containerView:(nonnull UIView *)containerView {
    ZFPresentController *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
    return player;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerViewTag:(NSInteger)containerViewTag {
    ZFPresentController *player = [[self alloc] initWithScrollView:scrollView playerManager:playerManager containerViewTag:containerViewTag];
    return player;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerView:(UIView *)containerView {
    ZFPresentController *player = [[self alloc] initWithScrollView:scrollView playerManager:playerManager containerView:containerView];
    return player;
}

- (instancetype)initWithPlayerManager:(id<ZFPresentStateWithback>)playerManager containerView:(nonnull UIView *)containerView {
    ZFPresentController *player = [self init];
    player.containerView = containerView;
    player.periodManager = playerManager;
    player.containerType = ZFPrimaryStageContainerTypeView;
    return player;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerViewTag:(NSInteger)containerViewTag {
    ZFPresentController *player = [self init];
    player.scrollView = scrollView;
    player.containerViewTag = containerViewTag;
    player.periodManager = playerManager;
    player.containerType = ZFPrimaryStageContainerTypeCell;
    return player;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPresentStateWithback>)playerManager containerView:(UIView *)containerView {
    ZFPresentController *player = [self init];
    player.scrollView = scrollView;
    player.containerView = containerView;
    player.periodManager = playerManager;
    player.containerType = ZFPrimaryStageContainerTypeView;
    return player;
}

- (void)playerManagerCallbcak {
    @zf_weakify(self)
    self.periodManager.presentPrepareToBegin = ^(id<ZFPresentStateWithback>  _Nonnull asset, NSURL * _Nonnull assetUsing) {
        @zf_strongify(self)
        if (self.resumeRecord && [_zfPlayRecords valueForKey:assetUsing.absoluteString]) {
            NSTimeInterval sleepTime = [_zfPlayRecords valueForKey:assetUsing.absoluteString].doubleValue;
            self.periodManager.sleepTime = sleepTime;
        }
        [self.notification addNotification];
        [self addDeviceOrientationObserver];
        if (self.scrollView) {
            self.scrollView.zf_stopPlay = NO;
        }
        [self layoutPlayerSubViews];
        if (self.presentPrepareToBegin) self.presentPrepareToBegin(asset,assetUsing);
        if ([self.controlView respondsToSelector:@selector(veryPractice:prepareToPlay:)]) {
            [self.controlView veryPractice:self prepareToPlay:assetUsing];
        }
    };
    
    self.periodManager.readyActiveToHave = ^(id<ZFPresentStateWithback>  _Nonnull asset, NSURL * _Nonnull assetUsing) {
        @zf_strongify(self)
        if (self.readyActiveToHave) self.readyActiveToHave(asset,assetUsing);
        if (!self.customAudioSession) {
            // Apps using this category don't mute when the phone's mute button is turned on, but play sound when the phone is silent
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
        if (self.viewControllerDisappear) self.pauseByEvent = YES;
    };
    
    self.periodManager.prettyTimeChanged = ^(id<ZFPresentStateWithback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @zf_strongify(self)
        if (self.prettyTimeChanged) self.prettyTimeChanged(asset,currentTime,duration);
        if ([self.controlView respondsToSelector:@selector(veryPractice:currentTime:tableTime:)]) {
            [self.controlView veryPractice:self currentTime:currentTime tableTime:duration];
        }
        if (self.periodManager.assetUsing.absoluteString) {
            [_zfPlayRecords setValue:@(currentTime) forKey:self.periodManager.assetUsing.absoluteString];
        }
    };
    
    self.periodManager.prettyBreadChanged = ^(id<ZFPresentStateWithback>  _Nonnull asset, NSTimeInterval presentTime) {
        @zf_strongify(self)
        if ([self.controlView respondsToSelector:@selector(veryPractice:presentTime:)]) {
            [self.controlView veryPractice:self presentTime:presentTime];
        }
        if (self.prettyBreadChanged) self.prettyBreadChanged(asset,presentTime);
    };
    
    self.periodManager.presentStateChanged = ^(id  _Nonnull asset, ZFPrimaryStagePresentState state) {
        @zf_strongify(self)
        if (self.presentStateChanged) self.presentStateChanged(asset, state);
        if ([self.controlView respondsToSelector:@selector(veryPractice:presentPoliteStateChangedpresentPoliteStateChangedpresentPoliteStateChanged:)]) {
            [self.controlView veryPractice:self presentPoliteStateChanged:state];
        }
    };
    
    self.periodManager.LoadNoteStateChanged = ^(id  _Nonnull asset, ZFPrimaryStageLoadState loadState) {
        @zf_strongify(self)
        if (loadState == ZFPrimaryStageLoadStatePrepare && CGSizeEqualToSize(CGSizeZero, self.periodManager.verySize)) {
            CGSize size = self.periodManager.view.frame.size;
            self.orientationObserver.verySize = size;
        }
        if (self.LoadNoteStateChanged) self.LoadNoteStateChanged(asset, loadState);
        if ([self.controlView respondsToSelector:@selector(veryPractice:stateLoadChanged:)]) {
            [self.controlView veryPractice:self stateLoadChanged:loadState];
        }
    };
    
    self.periodManager.prettyDidToEnd = ^(id  _Nonnull asset) {
        @zf_strongify(self)
        if (self.periodManager.assetUsing.absoluteString) {
            [_zfPlayRecords setValue:@(0) forKey:self.periodManager.assetUsing.absoluteString];
        }
        if (self.prettyDidToEnd) self.prettyDidToEnd(asset);
        if ([self.controlView respondsToSelector:@selector(veryPracticePointEnd:)]) {
            [self.controlView veryPracticePointEnd:self];
        }
    };
    
    self.periodManager.purpleFailed = ^(id<ZFPresentStateWithback>  _Nonnull asset, id  _Nonnull error) {
        @zf_strongify(self)
        if (self.purpleFailed) self.purpleFailed(asset, error);
        if ([self.controlView respondsToSelector:@selector(veryPracticePointFailed:error:)]) {
            [self.controlView veryPracticePointFailed:self error:error];
        }
    };
    
    self.periodManager.presentChangedSize = ^(id<ZFPresentStateWithback>  _Nonnull asset, CGSize size){
        @zf_strongify(self)
        self.orientationObserver.verySize = size;
        if (self.orientationObserver.fulfilledMode == ZFFineScheduleModeAutomatic) {
            if (size.width > size.height) {
                self.orientationObserver.fulfilledMode = ZFFineScheduleModeLandscape;
            } else {
                self.orientationObserver.fulfilledMode = ZFFineScheduleModePortrait;
            }
        }
        if (self.presentChangedSize) self.presentChangedSize(asset, size);
        if ([self.controlView respondsToSelector:@selector(veryPractice:presentChangedSize:)]) {
            [self.controlView veryPractice:self presentChangedSize:size];
        }
    };
}

- (void)layoutPlayerSubViews {
    if (self.containerView && self.periodManager.view && self.periodManager.isPreparedToPlace) {
        UIView *superview = nil;
        if (self.isFullScreen) {
            superview = self.orientationObserver.fullScreenContainerView;
        } else if (self.containerView) {
            superview = self.containerView;
        }
        [superview addSubview:self.periodManager.view];
        [self.periodManager.view addSubview:self.controlView];
        
        self.periodManager.view.frame = superview.bounds;
        self.periodManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.controlView.frame = self.periodManager.view.bounds;
        self.controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.orientationObserver updateRotateView:self.periodManager.view containerView:self.containerView];
    }
}

#pragma mark - getter

- (ZFPresentNotification *)notification {
    if (!_notification) {
        _notification = [[ZFPresentNotification alloc] init];
        @zf_weakify(self)
        _notification.willResignActive = ^(ZFPresentNotification * _Nonnull registrar) {
            @zf_strongify(self)
            if (self.isViewControllerDisappear) return;
            if (self.pauseWhenAppResignActive && self.periodManager.isPleasure) {
                self.pauseByEvent = YES;
            }
            self.orientationObserver.lockedScreen = YES;
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            if (!self.pauseWhenAppResignActive) {
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            }
        };
        _notification.didBecomeActive = ^(ZFPresentNotification * _Nonnull registrar) {
            @zf_strongify(self)
            if (self.isViewControllerDisappear) return;
            if (self.isPauseByEvent) self.pauseByEvent = NO;
            self.orientationObserver.lockedScreen = NO;
        };
        _notification.oldDeviceUnavailable = ^(ZFPresentNotification * _Nonnull registrar) {
            @zf_strongify(self)
            if (self.periodManager.isPleasure) {
                [self.periodManager play];
            }
        };
    }
    return _notification;
}

- (ZFFloatView *)smallFloatView {
    if (!_smallFloatView) {
        _smallFloatView = [[ZFFloatView alloc] init];
        _smallFloatView.parentView = [UIApplication sharedApplication].keyWindow;
        _smallFloatView.hidden = YES;
    }
    return _smallFloatView;
}

#pragma mark - setter

- (void)setPeriodManager:(id<ZFPresentStateWithback>)manager {
    if (!manager) return;
    if (_periodManager.isPreparedToPlace) {
        [_periodManager stop];
        [_periodManager.view removeFromSuperview];
        [self removeDeviceOrientationObserver];
        [self.gestureControl removeGestureToView:self.periodManager.view];
    }
    _periodManager = manager;
    self.gestureControl.disableTypes = self.disableGestureTypes;
    [self.gestureControl addGestureToView:manager.view];
    [self playerManagerCallbcak];
    self.controlView.primaryPretty = self;
    [self layoutPlayerSubViews];
    if (manager.isPreparedToPlace) {
        [self addDeviceOrientationObserver];
    }
    [self.orientationObserver updateRotateView:manager.view containerView:self.containerView];
}

- (void)setContainerView:(UIView *)view {
    _containerView = view;
    if (self.scrollView) {
        self.scrollView.zf_containerView = view;
    }
    if (!view) return;
    view.userInteractionEnabled = YES;
    [self layoutPlayerSubViews];
    [self.orientationObserver updateRotateView:self.periodManager.view containerView:view];
}

- (void)setControlView:(UIView<ZFPrimaryViewControl> *)view {
    if (view && view != _controlView) {
        [_controlView removeFromSuperview];
    }
    _controlView = view;
    if (!view) return;
    view.primaryPretty = self;
    [self layoutPlayerSubViews];
}

- (void)setContainerType:(ZFPrimaryStageContainerType)type {
    _containerType = type;
    if (self.scrollView) {
        self.scrollView.zf_containerType = type;
    }
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    self.scrollView.zf_WWANAutoPlay = self.isWWANAutoPlay;
    @zf_weakify(self)
    scrollView.presentStateWillAppearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (self.isFullScreen) return;
        if (self.presentStateWillAppearInScrollView) self.presentStateWillAppearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(primaryStageDidAppearInScrollView:)]) {
            [self.controlView primaryStageDidAppearInScrollView:self];
        }
    };
    
    scrollView.presentStateDidAppearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (self.isFullScreen) return;
        if (self.presentStateDidAppearInScrollView) self.presentStateDidAppearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(primaryStageDidAppearInScrollView:)]) {
            [self.controlView primaryStageDidAppearInScrollView:self];
        }
    };
    
    scrollView.presentStateWillDisappearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (self.isFullScreen) return;
        if (self.presentStateWillDisappearInScrollView) self.presentStateWillDisappearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerWillDisappearInScrollView:)]) {
            [self.controlView playerWillDisappearInScrollView:self];
        }
    };
    
    scrollView.presentStateDidDisappearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (self.isFullScreen) return;
        if (self.presentStateDidDisappearInScrollView) self.presentStateDidDisappearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(primaryStageDidDisappearInScrollView:)]) {
            [self.controlView primaryStageDidDisappearInScrollView:self];
        }
       
        if (self.stopWhileNotVisible) { /// stop playing
            if (self.containerType == ZFPrimaryStageContainerTypeView) {
                [self stopCurrentView];
            } else if (self.containerType == ZFPrimaryStageContainerTypeCell) {
                [self stopCurrentCell];
            }
        } else { /// add to window
            if (!self.isSmallFloatViewShow) {
                [self addPlayerViewToSmallFloatView];
            }
        }
    };
    
    scrollView.presentStateAppearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerApperaPercent) {
        @zf_strongify(self)
        if (self.isFullScreen) return;
        if (self.presentStateAppearingInScrollView) self.presentStateAppearingInScrollView(indexPath, playerApperaPercent);
        if ([self.controlView respondsToSelector:@selector(playerAppearingInScrollView:playerApperaPercent:)]) {
            [self.controlView playerAppearingInScrollView:self playerApperaPercent:playerApperaPercent];
        }
        if (!self.stopWhileNotVisible && playerApperaPercent >= self.playerApperaPercent) {
            if (self.containerType == ZFPrimaryStageContainerTypeView) {
                if (self.isSmallFloatViewShow) {
                    [self addPlayerViewToContainerView:self.containerView];
                }
            } else if (self.containerType == ZFPrimaryStageContainerTypeCell) {
                if (self.isSmallFloatViewShow) {
                    [self addPlayerViewToCell];
                }
            }
        }
    };
    
    scrollView.presentStateDisappearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerDisapperaPercent) {
        @zf_strongify(self)
        if (self.isFullScreen) return;
        if (self.presentStateDisappearingInScrollView) self.presentStateDisappearingInScrollView(indexPath, playerDisapperaPercent);
        if ([self.controlView respondsToSelector:@selector(playerDisappearingInScrollView:playerDisapperaPercent:)]) {
            [self.controlView playerDisappearingInScrollView:self playerDisapperaPercent:playerDisapperaPercent];
        }
        if (playerDisapperaPercent >= self.playerDisapperaPercent) {
            if (self.stopWhileNotVisible) { /// stop playing
                if (self.containerType == ZFPrimaryStageContainerTypeView) {
                    [self stopCurrentView];
                } else if (self.containerType == ZFPrimaryStageContainerTypeCell) {
                    [self stopCurrentCell];
                }
            } else {  /// add to window
                if (!self.isSmallFloatViewShow) {
                    [self addPlayerViewToSmallFloatView];
                }
            }
        }
    };
    
    scrollView.presentStateShouldPlayInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (self.presentStateShouldPlayInScrollView) self.presentStateShouldPlayInScrollView(indexPath);
    };
    
    scrollView.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (self.zf_scrollViewDidEndScrollingCallback) self.zf_scrollViewDidEndScrollingCallback(indexPath);
    };
}

@end

@implementation ZFPresentController (ZFPrimaryStageTimeControl)

- (NSTimeInterval)currentTime {
    return self.periodManager.currentTime;
}

- (NSTimeInterval)tableTime {
    return self.periodManager.tableTime;
}

- (NSTimeInterval)presentTime {
    return self.periodManager.presentTime;
}

- (float)percent {
    if (self.tableTime == 0) return 0;
    return self.currentTime/self.tableTime;
}

- (float)bufferProfile {
    if (self.tableTime == 0) return 0;
    return self.presentTime/self.tableTime;
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.periodManager seekToTime:time completionHandler:completionHandler];
}

@end

@implementation ZFPresentController (ZFPrimaryStagePlaybackControl)

- (void)playTheNext {
    if (self.assetURLs.count > 0) {
        NSInteger index = self.currentPlayIndex + 1;
        if (index >= self.assetURLs.count) return;
        NSURL *assetUsing = [self.assetURLs objectAtIndex:index];
        self.assetUsing = assetUsing;
        self.currentPlayIndex = [self.assetURLs indexOfObject:assetUsing];
    }
}

- (void)playThePrevious {
    if (self.assetURLs.count > 0) {
        NSInteger index = self.currentPlayIndex - 1;
        if (index < 0) return;
        NSURL *assetUsing = [self.assetURLs objectAtIndex:index];
        self.assetUsing = assetUsing;
        self.currentPlayIndex = [self.assetURLs indexOfObject:assetUsing];
    }
}

- (void)playTheIndex:(NSInteger)index {
    if (self.assetURLs.count > 0) {
        if (index >= self.assetURLs.count) return;
        NSURL *assetUsing = [self.assetURLs objectAtIndex:index];
        self.assetUsing = assetUsing;
        self.currentPlayIndex = index;
    }
}

- (void)stop {
    if (self.isFullScreen && self.exitFullScreenWhenStop) {
        @zf_weakify(self)
        [self.orientationObserver enterFineExample:NO animated:NO completion:^{
            @zf_strongify(self)
            [self.periodManager stop];
            [self.periodManager.view removeFromSuperview];
        }];
    } else {
        [self.periodManager stop];
        [self.periodManager.view removeFromSuperview];
    }
    self.lockedScreen = NO;
    if (self.scrollView) self.scrollView.zf_stopPlay = YES;
    [self.notification removeNotification];
    [self.orientationObserver removeDeviceOrientationObserver];
}

- (void)replaceCurrentManager:(id<ZFPresentStateWithback>)playerManager {
    self.periodManager = playerManager;
}

- (void)addPlayerViewToCell {
    self.isSmallFloatViewShow = NO;
    self.smallFloatView.hidden = YES;
    UIView *cell = [self.scrollView zf_getCellForIndexPath:self.playingIndexPath];
    self.containerView = [cell viewWithTag:self.containerViewTag];
    [self.containerView addSubview:self.periodManager.view];
    self.periodManager.view.frame = self.containerView.bounds;
    self.periodManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([self.controlView respondsToSelector:@selector(veryPractice:floatViewShow:)]) {
        [self.controlView veryPractice:self floatViewShow:NO];
    }
    [self layoutPlayerSubViews];
}

- (void)addPlayerViewToContainerView:(UIView *)containerView {
    self.isSmallFloatViewShow = NO;
    self.smallFloatView.hidden = YES;
    self.containerView = containerView;
    [self.containerView addSubview:self.periodManager.view];
    self.periodManager.view.frame = self.containerView.bounds;
    self.periodManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver updateRotateView:self.periodManager.view containerView:self.containerView];
    if ([self.controlView respondsToSelector:@selector(veryPractice:floatViewShow:)]) {
        [self.controlView veryPractice:self floatViewShow:NO];
    }
}

- (void)addPlayerViewToSmallFloatView {
    self.isSmallFloatViewShow = YES;
    self.smallFloatView.hidden = NO;
    [self.smallFloatView addSubview:self.periodManager.view];
    self.periodManager.view.frame = self.smallFloatView.bounds;
    self.periodManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver updateRotateView:self.periodManager.view containerView:self.smallFloatView];
    if ([self.controlView respondsToSelector:@selector(veryPractice:floatViewShow:)]) {
        [self.controlView veryPractice:self floatViewShow:YES];
    }
}

- (void)stopCurrentView {
    if (self.containerView) {
        [self stop];
        self.isSmallFloatViewShow = NO;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
    }
}

- (void)stopCurrentCell {
    if (self.scrollView.zf_playingIndexPath) {
        [self stop];
        self.isSmallFloatViewShow = NO;
        self.playingIndexPath = nil;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
    }
}

#pragma mark - getter

- (BOOL)resumeRecord {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (NSURL *)assetUsing {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSArray<NSURL *> *)assetURLs {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isLastAssetURL {
    if (self.assetURLs.count > 0) {
        return [self.assetUsing isEqual:self.assetURLs.lastObject];
    }
    return NO;
}

- (BOOL)isFirstAssetURL {
    if (self.assetURLs.count > 0) {
        return [self.assetUsing isEqual:self.assetURLs.firstObject];
    }
    return NO;
}

- (BOOL)isPauseByEvent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (float)brightness {
    return [UIScreen mainScreen].brightness;
}

- (float)vehicle {
    CGFloat vehicle = self.vehicleSlider.value;
    if (vehicle == 0) {
        vehicle = [[AVAudioSession sharedInstance] outputVolume];
    }
    return vehicle;
}

- (BOOL)ismethod {
    return self.vehicle == 0;
}

- (float)lastVehicleValue {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (ZFPrimaryStagePresentState)state {
    return self.periodManager.state;
}

- (BOOL)isPleasure {
    return self.periodManager.isPleasure;
}

- (BOOL)pauseWhenAppResignActive {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.pauseWhenAppResignActive = YES;
    return YES;
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, NSURL * _Nonnull))presentPrepareToBegin {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, NSURL * _Nonnull))readyActiveToHave {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, NSTimeInterval, NSTimeInterval))prettyTimeChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, NSTimeInterval))prettyBreadChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, ZFPrimaryStagePresentState))presentStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, ZFPrimaryStageLoadState))LoadNoteStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull))prettyDidToEnd {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, id _Nonnull))purpleFailed {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<ZFPresentStateWithback> _Nonnull, CGSize ))presentChangedSize {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSInteger)currentPlayIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)isViewControllerDisappear {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)customAudioSession {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setResumeRecord:(BOOL)resumeRecord {
    objc_setAssociatedObject(self, @selector(resumeRecord), @(resumeRecord), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setAssetUsing:(NSURL *)assetUsing {
    objc_setAssociatedObject(self, @selector(assetUsing), assetUsing, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.periodManager.assetUsing = assetUsing;
}

- (void)setAssetURLs:(NSArray<NSURL *> * _Nullable)assetURLs {
    objc_setAssociatedObject(self, @selector(assetURLs), assetURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setVehicle:(float)vehicle {
    vehicle = MIN(MAX(0, vehicle), 1);
    objc_setAssociatedObject(self, @selector(vehicle), @(vehicle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.vehicleSlider.value = vehicle;
}

- (void)setMethod:(BOOL)method {
    if (method) {
        if (self.vehicleSlider.value > 0) {
            self.lastVehicleValue = self.vehicleSlider.value;
        }
        self.vehicleSlider.value = 0;
    } else {
        self.vehicleSlider.value = self.lastVehicleValue;
    }
}

- (void)setLastVehicleValue:(float)lastVehicleValue {
    objc_setAssociatedObject(self, @selector(lastVehicleValue), @(lastVehicleValue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBrightness:(float)brightness {
    brightness = MIN(MAX(0, brightness), 1);
    objc_setAssociatedObject(self, @selector(brightness), @(brightness), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [UIScreen mainScreen].brightness = brightness;
}

- (void)setPauseByEvent:(BOOL)pauseByEvent {
    objc_setAssociatedObject(self, @selector(isPauseByEvent), @(pauseByEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (pauseByEvent) {
        [self.periodManager pause];
    } else {
        [self.periodManager play];
    }
}

- (void)setPauseWhenAppResignActive:(BOOL)pauseWhenAppResignActive {
    objc_setAssociatedObject(self, @selector(pauseWhenAppResignActive), @(pauseWhenAppResignActive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPresentPrepareToBegin:(void (^)(id<ZFPresentStateWithback> _Nonnull, NSURL * _Nonnull))presentPrepareToBegin {
    objc_setAssociatedObject(self, @selector(presentPrepareToBegin), presentPrepareToBegin, OBJC_ASSOCIATION_COPY);
}

- (void)setReadyActiveToHave:(void (^)(id<ZFPresentStateWithback> _Nonnull, NSURL * _Nonnull))readyActiveToHave {
    objc_setAssociatedObject(self, @selector(readyActiveToHave), readyActiveToHave, OBJC_ASSOCIATION_COPY);
}

- (void)setPrettyTimeChanged:(void (^)(id<ZFPresentStateWithback> _Nonnull, NSTimeInterval, NSTimeInterval))prettyTimeChanged {
    objc_setAssociatedObject(self, @selector(prettyTimeChanged), prettyTimeChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPrettyBreadChanged:(void (^)(id<ZFPresentStateWithback> _Nonnull, NSTimeInterval))prettyBreadChanged {
    objc_setAssociatedObject(self, @selector(prettyBreadChanged), prettyBreadChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPresentStateChanged:(void (^)(id<ZFPresentStateWithback> _Nonnull, ZFPrimaryStagePresentState))presentStateChanged {
    objc_setAssociatedObject(self, @selector(presentStateChanged), presentStateChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPoadNoteStateChanged:(void (^)(id<ZFPresentStateWithback> _Nonnull, ZFPrimaryStageLoadState))LoadNoteStateChanged {
    objc_setAssociatedObject(self, @selector(LoadNoteStateChanged), LoadNoteStateChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPrettyDidToEnd:(void (^)(id<ZFPresentStateWithback> _Nonnull))prettyDidToEnd {
    objc_setAssociatedObject(self, @selector(prettyDidToEnd), prettyDidToEnd, OBJC_ASSOCIATION_COPY);
}

- (void)setPurpleFailed:(void (^)(id<ZFPresentStateWithback> _Nonnull, id _Nonnull))purpleFailed {
    objc_setAssociatedObject(self, @selector(purpleFailed), purpleFailed, OBJC_ASSOCIATION_COPY);
}

- (void)setPresentChangedSize:(void (^)(id<ZFPresentStateWithback> _Nonnull, CGSize))presentChangedSize {
    objc_setAssociatedObject(self, @selector(verySize), presentChangedSize, OBJC_ASSOCIATION_COPY);
}

- (void)setCurrentPlayIndex:(NSInteger)currentPlayIndex {
    objc_setAssociatedObject(self, @selector(currentPlayIndex), @(currentPlayIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setViewControllerDisappear:(BOOL)viewControllerDisappear {
    objc_setAssociatedObject(self, @selector(isViewControllerDisappear), @(viewControllerDisappear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.scrollView) self.scrollView.zf_viewControllerDisappear = viewControllerDisappear;
    if (!self.periodManager.isPreparedToPlace) return;
    if (viewControllerDisappear) {
        [self removeDeviceOrientationObserver];
        if (self.periodManager.isPleasure) self.pauseByEvent = YES;
        if (self.isSmallFloatViewShow) self.smallFloatView.hidden = YES;
    } else {
        [self addDeviceOrientationObserver];
        if (self.isPauseByEvent) self.pauseByEvent = NO;
        if (self.isSmallFloatViewShow) self.smallFloatView.hidden = NO;
    }
}

- (void)setCustomAudioSession:(BOOL)customAudioSession {
    objc_setAssociatedObject(self, @selector(customAudioSession), @(customAudioSession), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation ZFPresentController (ZFPrimaryStageOrientationRotation)

- (void)addDeviceOrientationObserver {
    if (self.allowOrentitaionRotation) {
        [self.orientationObserver addDeviceOrientationObserver];
    }
}

- (void)removeDeviceOrientationObserver {
    [self.orientationObserver removeDeviceOrientationObserver];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    [self rotateToOrientation:orientation animated:animated completion:nil];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion {
    self.orientationObserver.fulfilledMode = ZFFineScheduleModeLandscape;
    [self.orientationObserver rotateToOrientation:orientation animated:animated completion:completion];
}

- (void)enterPortraitFineExample:(BOOL)example animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion {
    self.orientationObserver.fulfilledMode = ZFFineScheduleModePortrait;
    [self.orientationObserver enterPortraitFineExample:example animated:animated completion:completion];
}

- (void)enterPortraitFineExample:(BOOL)example animated:(BOOL)animated {
    [self enterPortraitFineExample:example animated:animated completion:nil];
}

- (void)enterFineExample:(BOOL)example animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion {
    if (self.orientationObserver.fulfilledMode == ZFFineScheduleModePortrait) {
        [self.orientationObserver enterPortraitFineExample:example animated:animated completion:completion];
    } else {
        UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
        orientation = example? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
        [self.orientationObserver rotateToOrientation:orientation animated:animated completion:completion];
    }
}

- (void)enterFineExample:(BOOL)example animated:(BOOL)animated {
    [self enterFineExample:example animated:animated completion:nil];
}

#pragma mark - getter

- (ZFOrientationObserver *)orientationObserver {
    @zf_weakify(self)
    ZFOrientationObserver *orientationObserver = objc_getAssociatedObject(self, _cmd);
    if (!orientationObserver) {
        orientationObserver = [[ZFOrientationObserver alloc] init];
        orientationObserver.orientationWillChange = ^(ZFOrientationObserver * _Nonnull observer, BOOL isFullScreen) {
            @zf_strongify(self)
            if (self.orientationWillChange) self.orientationWillChange(self, isFullScreen);
            if ([self.controlView respondsToSelector:@selector(veryPractice:orientationWillChange:)]) {
                [self.controlView veryPractice:self orientationWillChange:observer];
            }
            [self.controlView setNeedsLayout];
            [self.controlView layoutIfNeeded];
        };
        orientationObserver.orientationDidChanged = ^(ZFOrientationObserver * _Nonnull observer, BOOL isFullScreen) {
            @zf_strongify(self)
            if (self.orientationDidChanged) self.orientationDidChanged(self, isFullScreen);
            if ([self.controlView respondsToSelector:@selector(veryPractice:orientationDidChanged:)]) {
                [self.controlView veryPractice:self orientationDidChanged:observer];
            }
        };
        objc_setAssociatedObject(self, _cmd, orientationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return orientationObserver;
}

- (void (^)(ZFPresentController * _Nonnull, BOOL))orientationWillChange {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(ZFPresentController * _Nonnull, BOOL))orientationDidChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isFullScreen {
    return self.orientationObserver.isFullScreen;
}

- (BOOL)exitFullScreenWhenStop {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.exitFullScreenWhenStop = YES;
    return YES;
}

- (BOOL)isStatusBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)allowOrentitaionRotation {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.allowOrentitaionRotation = YES;
    return YES;
}

- (UIStatusBarStyle)fullScreenStatusBarStyle {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.integerValue;
    self.fullScreenStatusBarStyle = UIStatusBarStyleLightContent;
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)fullScreenStatusBarAnimation {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.integerValue;
    self.fullScreenStatusBarAnimation = UIStatusBarAnimationNone;
    return UIStatusBarAnimationNone;
}

#pragma mark - setter

- (void)setOrientationWillChange:(void (^)(ZFPresentController * _Nonnull, BOOL))orientationWillChange {
    objc_setAssociatedObject(self, @selector(orientationWillChange), orientationWillChange, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setOrientationDidChanged:(void (^)(ZFPresentController * _Nonnull, BOOL))orientationDidChanged {
    objc_setAssociatedObject(self, @selector(orientationDidChanged), orientationDidChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    objc_setAssociatedObject(self, @selector(isStatusBarHidden), @(statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.fullScreenStatusBarHidden = statusBarHidden;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.lockedScreen = lockedScreen;
    if ([self.controlView respondsToSelector:@selector(lockedVeryPractice:practiced:)]) {
        [self.controlView lockedVeryPractice:self practiced:lockedScreen];
    }
}

- (void)setAllowOrentitaionRotation:(BOOL)allowOrentitaionRotation {
    objc_setAssociatedObject(self, @selector(allowOrentitaionRotation), @(allowOrentitaionRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.allowOrientationRotation = allowOrentitaionRotation;
}

- (void)setExitFullScreenWhenStop:(BOOL)exitFullScreenWhenStop {
    objc_setAssociatedObject(self, @selector(exitFullScreenWhenStop), @(exitFullScreenWhenStop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setFullScreenStatusBarStyle:(UIStatusBarStyle)fullScreenStatusBarStyle {
    objc_setAssociatedObject(self, @selector(fullScreenStatusBarStyle), @(fullScreenStatusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.fullScreenStatusBarStyle = fullScreenStatusBarStyle;
}

- (void)setFullScreenStatusBarAnimation:(UIStatusBarAnimation)fullScreenStatusBarAnimation {
    objc_setAssociatedObject(self, @selector(fullScreenStatusBarAnimation), @(fullScreenStatusBarAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.fullScreenStatusBarAnimation = fullScreenStatusBarAnimation;
}

@end


@implementation ZFPresentController (ZFPresentViewGesture)

#pragma mark - getter

- (ZFPresentGestureControl *)gestureControl {
    ZFPresentGestureControl *gestureControl = objc_getAssociatedObject(self, _cmd);
    if (!gestureControl) {
        gestureControl = [[ZFPresentGestureControl alloc] init];
        @zf_weakify(self)
        gestureControl.triggerCondition = ^BOOL(ZFPresentGestureControl * _Nonnull control, ZFPrimaryStageGestureType type, UIGestureRecognizer * _Nonnull gesture, UITouch *touch) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureTriggerCondition:gestureType:gestureRecognizer:touch:)]) {
                return [self.controlView gestureTriggerCondition:control gestureType:type gestureRecognizer:gesture touch:touch];
            }
            return YES;
        };
        
        gestureControl.singleTapped = ^(ZFPresentGestureControl * _Nonnull control) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureSingleTapped:)]) {
                [self.controlView gestureSingleTapped:control];
            }
        };
        
        gestureControl.doubleTapped = ^(ZFPresentGestureControl * _Nonnull control) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureDoubleTapped:)]) {
                [self.controlView gestureDoubleTapped:control];
            }
        };
        
        gestureControl.beganPan = ^(ZFPresentGestureControl * _Nonnull control, ZFPanDirection direction, ZFPanLocation location) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureBeganPan:panDirection:panLocation:)]) {
                [self.controlView gestureBeganPan:control panDirection:direction panLocation:location];
            }
        };
        
        gestureControl.changedPan = ^(ZFPresentGestureControl * _Nonnull control, ZFPanDirection direction, ZFPanLocation location, CGPoint velocity) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureChangedPan:panDirection:panLocation:withVelocity:)]) {
                [self.controlView gestureChangedPan:control panDirection:direction panLocation:location withVelocity:velocity];
            }
        };
        
        gestureControl.endedPan = ^(ZFPresentGestureControl * _Nonnull control, ZFPanDirection direction, ZFPanLocation location) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureEndedPan:panDirection:panLocation:)]) {
                [self.controlView gestureEndedPan:control panDirection:direction panLocation:location];
            }
        };
        
        gestureControl.pinched = ^(ZFPresentGestureControl * _Nonnull control, float scale) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(gesturePinched:scale:)]) {
                [self.controlView gesturePinched:control scale:scale];
            }
        };
        
        gestureControl.longPressed = ^(ZFPresentGestureControl * _Nonnull control, ZFLongPressGestureRecognizerState state) {
            @zf_strongify(self)
            if ([self.controlView respondsToSelector:@selector(longPressed:state:)]) {
                [self.controlView longPressed:control state:state];
            }
        };
        objc_setAssociatedObject(self, _cmd, gestureControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gestureControl;
}

- (ZFPrimaryStageDisableGestureTypes)disableGestureTypes {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (ZFPrimaryStageDisablePanMovingDirection)disablePanMovingDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

#pragma mark - setter

- (void)setDisableGestureTypes:(ZFPrimaryStageDisableGestureTypes)disableGestureTypes {
    objc_setAssociatedObject(self, @selector(disableGestureTypes), @(disableGestureTypes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.gestureControl.disableTypes = disableGestureTypes;
}

- (void)setDisablePanMovingDirection:(ZFPrimaryStageDisablePanMovingDirection)disablePanMovingDirection {
    objc_setAssociatedObject(self, @selector(disablePanMovingDirection), @(disablePanMovingDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.gestureControl.disablePanMovingDirection = disablePanMovingDirection;
}

@end

@implementation ZFPresentController (ZFPrimaryStageScrollView)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            NSSelectorFromString(@"dealloc")
        };
        
        for (NSInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"zf_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

- (void)zf_dealloc {
    [self.smallFloatView removeFromSuperview];
    self.smallFloatView = nil;
    [self zf_dealloc];
}

#pragma mark - setter

- (void)setWWANAutoPlay:(BOOL)WWANAutoPlay {
    objc_setAssociatedObject(self, @selector(isWWANAutoPlay), @(WWANAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.scrollView) self.scrollView.zf_WWANAutoPlay = self.isWWANAutoPlay;
}

- (void)setStopWhileNotVisible:(BOOL)stopWhileNotVisible {
    self.scrollView.zf_stopWhileNotVisible = stopWhileNotVisible;
    objc_setAssociatedObject(self, @selector(stopWhileNotVisible), @(stopWhileNotVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setContainerViewTag:(NSInteger)containerViewTag {
    objc_setAssociatedObject(self, @selector(containerViewTag), @(containerViewTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.zf_containerViewTag = containerViewTag;
}

- (void)setPlayingIndexPath:(NSIndexPath *)playingIndexPath {
    objc_setAssociatedObject(self, @selector(playingIndexPath), playingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (playingIndexPath) {
        self.isSmallFloatViewShow = NO;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
        
        UIView *cell = [self.scrollView zf_getCellForIndexPath:playingIndexPath];
        self.containerView = [cell viewWithTag:self.containerViewTag];
        [self addDeviceOrientationObserver];
        self.scrollView.zf_playingIndexPath = playingIndexPath;
        [self layoutPlayerSubViews];
    } else {
        self.scrollView.zf_playingIndexPath = playingIndexPath;
    }
}

- (void)setShouldPractice:(BOOL)shouldPractice {
    objc_setAssociatedObject(self, @selector(shouldPractice), @(shouldPractice), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.shouldPractice = shouldPractice;
}

- (void)setSectionAssetURLs:(NSArray<NSArray<NSURL *> *> * _Nullable)sectionAssetURLs {
    objc_setAssociatedObject(self, @selector(sectionAssetURLs), sectionAssetURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerDisapperaPercent:(CGFloat)playerDisapperaPercent {
    playerDisapperaPercent = MIN(MAX(0.0, playerDisapperaPercent), 1.0);
    self.scrollView.presentStateDisapperaPercent = playerDisapperaPercent;
    objc_setAssociatedObject(self, @selector(playerDisapperaPercent), @(playerDisapperaPercent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerApperaPercent:(CGFloat)playerApperaPercent {
    playerApperaPercent = MIN(MAX(0.0, playerApperaPercent), 1.0);
    self.scrollView.presentStateApperaPercent = playerApperaPercent;
    objc_setAssociatedObject(self, @selector(playerApperaPercent), @(playerApperaPercent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPresentStateAppearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateAppearingInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateAppearingInScrollView), presentStateAppearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateDisappearingInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateDisappearingInScrollView), presentStateDisappearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateDidAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateDidAppearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateDidAppearInScrollView), presentStateDidAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateWillDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateWillDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateWillDisappearInScrollView), presentStateWillDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateWillAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStaterWillAppearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateWillAppearInScrollView), presentStaterWillAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateDidDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStaterDidDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateDidDisappearInScrollView), presentStaterDidDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateShouldPlayInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateShouldPlayInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateShouldPlayInScrollView), presentStateShouldPlayInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setZf_scrollViewDidEndScrollingCallback:(void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidEndScrollingCallback {
    objc_setAssociatedObject(self, @selector(zf_scrollViewDidEndScrollingCallback), zf_scrollViewDidEndScrollingCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - getter

- (BOOL)isWWANAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)stopWhileNotVisible {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.stopWhileNotVisible = YES;
    return YES;
}

- (NSInteger)containerViewTag {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (NSIndexPath *)playingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSIndexPath *)shouldPlayIndexPath {
    return self.scrollView.zf_shouldPlayIndexPath;
}

- (NSArray<NSArray<NSURL *> *> *)sectionAssetURLs {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)shouldPractice {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (CGFloat)playerDisapperaPercent {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.floatValue;
    self.playerDisapperaPercent = 0.5;
    return 0.5;
}

- (CGFloat)playerApperaPercent {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.floatValue;
    self.playerApperaPercent = 0.0;
    return 0.0;
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateAppearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateDisappearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateDidAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateWillDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateWillAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateDidDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateShouldPlayInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidEndScrollingCallback {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Public method

- (void)zf_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    [self.scrollView zf_filterShouldPlayCellWhileScrolled:handler];
}

- (void)zf_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    [self.scrollView zf_filterShouldPlayCellWhileScrolling:handler];
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath {
    self.playingIndexPath = indexPath;
    NSURL *assetUsing;
    if (self.sectionAssetURLs.count) {
        assetUsing = self.sectionAssetURLs[indexPath.section][indexPath.row];
    } else if (self.assetURLs.count) {
        assetUsing = self.assetURLs[indexPath.row];
        self.currentPlayIndex = indexPath.row;
    }
    self.assetUsing = assetUsing;
}


- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition animated:(BOOL)animated {
    [self playTheIndexPath:indexPath scrollPosition:scrollPosition animated:animated completionHandler:nil];
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler {
    NSURL *assetUsing;
    if (self.sectionAssetURLs.count) {
        assetUsing = self.sectionAssetURLs[indexPath.section][indexPath.row];
    } else if (self.assetURLs.count) {
        assetUsing = self.assetURLs[indexPath.row];
        self.currentPlayIndex = indexPath.row;
    }
    @zf_weakify(self)
    [self.scrollView zf_scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated completionHandler:^{
        @zf_strongify(self)
        if (completionHandler) completionHandler();
        self.playingIndexPath = indexPath;
        self.assetUsing = assetUsing;
    }];
}


- (void)playTheIndexPath:(NSIndexPath *)indexPath assetUsing:(NSURL *)assetUsing {
    self.playingIndexPath = indexPath;
    self.assetUsing = assetUsing;
}


- (void)playTheIndexPath:(NSIndexPath *)indexPath
                assetUsing:(NSURL *)assetUsing
          scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                animated:(BOOL)animated {
    [self playTheIndexPath:indexPath assetUsing:assetUsing scrollPosition:scrollPosition animated:animated completionHandler:nil];
}


- (void)playTheIndexPath:(NSIndexPath *)indexPath
                assetUsing:(NSURL *)assetUsing
          scrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                animated:(BOOL)animated
       completionHandler:(void (^ __nullable)(void))completionHandler {
    @zf_weakify(self)
    [self.scrollView zf_scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated completionHandler:^{
        @zf_strongify(self)
        if (completionHandler) completionHandler();
        self.playingIndexPath = indexPath;
        self.assetUsing = assetUsing;
    }];
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation ZFPresentController (ZFPrimaryStageDeprecated)

- (void)updateScrollViewPlayerToCell {
    if (self.periodManager.view && self.playingIndexPath && self.containerViewTag) {
        UIView *cell = [self.scrollView zf_getCellForIndexPath:self.playingIndexPath];
        self.containerView = [cell viewWithTag:self.containerViewTag];
        [self layoutPlayerSubViews];
    }
}

- (void)updateNoramlPlayerWithContainerView:(UIView *)containerView {
    if (self.periodManager.view && self.containerView) {
        self.containerView = containerView;
        [self.orientationObserver updateRotateView:self.periodManager.view containerView:self.containerView];
        [self layoutPlayerSubViews];
    }
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop completionHandler:(void (^ _Nullable)(void))completionHandler {
    NSURL *assetUsing;
    if (self.sectionAssetURLs.count) {
        assetUsing = self.sectionAssetURLs[indexPath.section][indexPath.row];
    } else if (self.assetURLs.count) {
        assetUsing = self.assetURLs[indexPath.row];
        self.currentPlayIndex = indexPath.row;
    }
    if (scrollToTop) {
        @zf_weakify(self)
        [self.scrollView zf_scrollToRowAtIndexPath:indexPath completionHandler:^{
            @zf_strongify(self)
            if (completionHandler) completionHandler();
            self.playingIndexPath = indexPath;
            self.assetUsing = assetUsing;
        }];
    } else {
        if (completionHandler) completionHandler();
        self.playingIndexPath = indexPath;
        self.assetUsing = assetUsing;
    }
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    if ([indexPath compare:self.playingIndexPath] == NSOrderedSame) return;
    if (scrollToTop) {
        @zf_weakify(self)
        [self.scrollView zf_scrollToRowAtIndexPath:indexPath completionHandler:^{
            @zf_strongify(self)
            [self playTheIndexPath:indexPath];
        }];
    } else {
        [self playTheIndexPath:indexPath];
    }
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath assetUsing:(NSURL *)assetUsing scrollToTop:(BOOL)scrollToTop {
    self.playingIndexPath = indexPath;
    self.assetUsing = assetUsing;
    if (scrollToTop) {
        [self.scrollView zf_scrollToRowAtIndexPath:indexPath completionHandler:nil];
    }
}

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion {
    self.orientationObserver.fulfilledMode = ZFFineScheduleModeLandscape;
    [self.orientationObserver rotateToOrientation:orientation animated:animated completion:completion];
}

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    [self enterLandscapeFullScreen:orientation animated:animated completion:nil];
}

/// Add to the keyWindow
- (void)addPlayerViewToKeyWindow {
    [self addPlayerViewToSmallFloatView];
}

@end

#pragma clang diagnostic pop
