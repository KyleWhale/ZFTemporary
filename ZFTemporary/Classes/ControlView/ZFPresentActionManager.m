
#import "ZFPresentActionManager.h"
#import <UIKit/UIKit.h>
#import "ZFKVOController.h"
#import "ZFPrimaryConst.h"
#import "ZFReachabilityManager.h"
#import "ZFAdManager.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

static NSString *const kStatus                   = @"status";
static NSString *const kLittleTypeRanges         = @"loadedTimeRanges";
static NSString *const kPresentbackEmpty         = @"playbackBufferEmpty";
static NSString *const kPresentbackLikelyUp      = @"playbackLikelyToKeepUp";
static NSString *const kVerySize                 = @"presentationSize";

@interface ZFPurplePresentView : UIView

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVLayerVideoGravity greenVegetables;

@end

@implementation ZFPurplePresentView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)setPlayer:(AVPlayer *)type {
    if (type == _player) return;
    self.avLayer.player = type;
}

- (void)setGreenVegetables:(AVLayerVideoGravity)greenVegetables {
    if (greenVegetables == self.greenVegetables) return;
    [self avLayer].videoGravity = greenVegetables;
}

- (AVLayerVideoGravity)greenVegetables {
    return [self avLayer].videoGravity;
}

@end

@interface ZFPresentActionManager () {
    id _timeObserver;
    id _itemEndObserver;
    ZFKVOController *_prettyItemKVO;
}
@property (nonatomic, strong) AVPlayerLayer *presentLayer;
@property (nonatomic, assign) BOOL isBecome;
@property (nonatomic, assign) BOOL isRespect;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation ZFPresentActionManager

@synthesize view                           = _view;
@synthesize currentTime                    = _currentTime;
@synthesize tableTime                      = _tableTime;
@synthesize prettyTimeChanged              = _prettyTimeChanged;
@synthesize prettyBreadChanged             = _prettyBreadChanged;
@synthesize prettyDidToEnd                 = _prettyDidToEnd;
@synthesize presentTime                    = _presentTime;
@synthesize state                          = _state;
@synthesize loadState                      = _loadState;
@synthesize assetUsing                     = _assetUsing;
@synthesize presentPrepareToBegin          = _presentPrepareToBegin;
@synthesize readyActiveToHave              = _readyActiveToHave;
@synthesize presentStateChanged            = _presentStateChanged;
@synthesize LoadNoteStateChanged           = _LoadNoteStateChanged;
@synthesize sleepTime                      = _sleepTime;
@synthesize method                         = _method;
@synthesize vehicle                        = _vehicle;
@synthesize verySize                       = _verySize;
@synthesize itemPleasure                   = _itemPleasure;
@synthesize resultRest                     = _resultRest;
@synthesize isPreparedToPlace              = _isPreparedToPlace;
@synthesize shouldPractice                 = _shouldPractice;
@synthesize scalingMode                    = _scalingMode;
@synthesize purpleFailed                   = _purpleFailed;
@synthesize presentChangedSize             = _presentChangedSize;

- (instancetype)init {
    self = [super init];
    if (self) {
        _scalingMode = ZFPrimaryStageScalingModeAspectFill;
        _shouldPractice = YES;
    }
    return self;
}

- (void)prepareToPlay {
    if (!_assetUsing) return;
    _isPreparedToPlace = YES;
    [self initializePractice];
    if (self.shouldPractice) {
        [self play];
    }
    self.loadState = ZFPrimaryStageLoadStatePrepare;
    if (self.presentPrepareToBegin) self.presentPrepareToBegin(self, self.assetUsing);
}

- (void)reloadPresent {
    self.sleepTime = self.currentTime;
    [self prepareToPlay];
}

- (void)play {
    if (!_isPreparedToPlace) {
        [self prepareToPlay];
    } else {
        [self.primaryStage play];
        self.primaryStage.rate = self.resultRest;
        self->_itemPleasure = YES;
        self.state = ZFPrimaryStagePresentStatePolite;
    }
    if([ZFAdManager.shared.ad show] || ZFAdManager.shared.ad.enter){
        [self pause];
    }
}

- (void)pause:(BOOL)tempPause{
    [self.primaryStage pause];
    self.tempPause = tempPause;
    self->_itemPleasure = NO;
    self.state = ZFPrimaryStagePresentStatePattern;
    [_primaryStageItem cancelPendingSeeks];
    [_asset cancelLoading];
}

- (void)pause {
    [self pause:NO];
}

- (void)stop {
    [_prettyItemKVO safelyRemoveAllObservers];
    self.loadState = ZFPrimaryStageLoadStateUnknown;
    self.state = ZFPrimaryStagePresentStateStopped;
    if (self.primaryStage.rate != 0) [self.primaryStage pause];
    [_primaryStageItem cancelPendingSeeks];
    [_asset cancelLoading];
    [self.primaryStage removeTimeObserver:_timeObserver];
    [self.primaryStage replaceCurrentItemWithPlayerItem:nil];
    self.verySize = CGSizeZero;
    _timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.primaryStageItem];
    _itemEndObserver = nil;
    _itemPleasure = NO;
    _primaryStage = nil;
    _assetUsing = nil;
    _primaryStageItem = nil;
    _isPreparedToPlace = NO;
    self->_currentTime = 0;
    self->_tableTime = 0;
    self->_presentTime = 0;
    self.isRespect = NO;
}

- (void)replay {
    @zf_weakify(self)
    [self seekToTime:0 completionHandler:^(BOOL finished) {
        @zf_strongify(self)
        [self play];
    }];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if (self.tableTime > 0) {
        [_primaryStage.currentItem cancelPendingSeeks];
        int32_t timeScale = _primaryStage.currentItem.asset.duration.timescale;
        CMTime sleepTime = CMTimeMakeWithSeconds(time, timeScale);
        [_primaryStage seekToTime:sleepTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
    } else {
        self.sleepTime = time;
    }
}

- (UIImage *)thumbnailImageAtCurrentTime {
    CMTime expectedTime = self.primaryStageItem.currentTime;
    CGImageRef cgImage = NULL;
    
    self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    cgImage = [self.imageGenerator copyCGImageAtTime:expectedTime actualTime:NULL error:NULL];

    if (!cgImage) {
        self.imageGenerator.requestedTimeToleranceBefore = kCMTimePositiveInfinity;
        self.imageGenerator.requestedTimeToleranceAfter = kCMTimePositiveInfinity;
        cgImage = [self.imageGenerator copyCGImageAtTime:expectedTime actualTime:NULL error:NULL];
    }
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    return image;
}

- (void)thumbnailImageAtCurrentTime:(void(^)(UIImage *))handler {
    CMTime expectedTime = self.primaryStageItem.currentTime;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:expectedTime]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (handler) {
            UIImage *finalImage = [UIImage imageWithCGImage:image];
            handler(finalImage);
        }
    }];
}

#pragma mark - private method

- (NSTimeInterval)availableDuration {
    NSArray *timeRangeArray = _primaryStageItem.loadedTimeRanges;
    CMTime currentTime = [_primaryStage currentTime];
    BOOL foundRange = NO;
    CMTimeRange aTimeRange = {0};
    if (timeRangeArray.count) {
        aTimeRange = [[timeRangeArray objectAtIndex:0] CMTimeRangeValue];
        if (CMTimeRangeContainsTime(aTimeRange, currentTime)) {
            foundRange = YES;
        }
    }
    
    if (foundRange) {
        CMTime maxTime = CMTimeRangeGetEnd(aTimeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if (playableDuration > 0) {
            return playableDuration;
        }
    }
    return 0;
}

- (void)initializePractice {
    _asset = [AVURLAsset URLAssetWithURL:self.assetUsing options:self.requestHeader];
    _primaryStageItem = [AVPlayerItem playerItemWithAsset:_asset];
    _primaryStage = [AVPlayer playerWithPlayerItem:_primaryStageItem];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];

    [self enableAudioTracks:YES inPlayerItem:_primaryStageItem];
    
    ZFPurplePresentView *presentView = [[ZFPurplePresentView alloc] init];
    presentView.player = _primaryStage;
    self.view.playerView = presentView;

    self.scalingMode = _scalingMode;
    if (@available(iOS 9.0, *)) {
        _primaryStageItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    }
    if (@available(iOS 10.0, *)) {
        _primaryStageItem.preferredForwardBufferDuration = 5;
        _primaryStage.automaticallyWaitsToMinimizeStalling = NO;
    }
    [self itemObserving];
}

- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem {
    for (AVPlayerItemTrack *track in playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeVideo]) {
            track.enabled = enable;
        }
    }
}

- (void)bufferingSomeSecond {
    if (self.isBecome || self.state == ZFPrimaryStagePresentStateStopped) return;
    if ([ZFReachabilityManager sharedManager].networkReachabilityStatus == ZFReachabilityStatusNotReachable) return;
    self.isBecome = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.itemPleasure && self.loadState == ZFPrimaryStageLoadStateStalled) {
            self.isBecome = NO;
            return;
        }
        if(![ZFAdManager.shared.ad show]){
            [self play];
            self.isBecome = NO;
            if (!self.primaryStageItem.isPlaybackLikelyToKeepUp) [self bufferingSomeSecond];
        }
    });
}

- (void)itemObserving {
    [_prettyItemKVO safelyRemoveAllObservers];
    _prettyItemKVO = [[ZFKVOController alloc] initWithTarget:_primaryStageItem];
    [_prettyItemKVO safelyAddObserver:self
                           forKeyPath:kStatus
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    [_prettyItemKVO safelyAddObserver:self
                           forKeyPath:kPresentbackEmpty
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    [_prettyItemKVO safelyAddObserver:self
                           forKeyPath:kPresentbackLikelyUp
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    [_prettyItemKVO safelyAddObserver:self
                           forKeyPath:kLittleTypeRanges
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    [_prettyItemKVO safelyAddObserver:self
                           forKeyPath:kVerySize
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    
    CMTime interval = CMTimeMakeWithSeconds(self.timeRefreshInterval > 0 ? self.timeRefreshInterval : 0.1, NSEC_PER_SEC);
    @zf_weakify(self)
    _timeObserver = [self.primaryStage addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @zf_strongify(self)
        if (!self) return;
        NSArray *loadedRanges = self.primaryStageItem.seekableTimeRanges;
        if (self.itemPleasure && self.loadState == ZFPrimaryStageLoadStateStalled) self.primaryStage.rate = self.resultRest;
        if (loadedRanges.count > 0) {
            if (self.prettyTimeChanged) self.prettyTimeChanged(self, self.currentTime, self.tableTime);
        }
    }];
    
    _itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.primaryStageItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @zf_strongify(self)
        if (!self) return;
        self.state = ZFPrimaryStagePresentStateStopped;
        if (self.prettyDidToEnd) self.prettyDidToEnd(self);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:kStatus]) {
            if (self.primaryStage.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                if (!self.isRespect) {
                    self.isRespect = YES;
                    self.loadState = ZFPrimaryStageLoadStatePlaythroughOK;
                    if (self.readyActiveToHave) self.readyActiveToHave(self, self.assetUsing);
                }
                if (self.sleepTime) {
                    if (self.shouldPractice) [self pause];
                    @zf_weakify(self)
                    [self seekToTime:self.sleepTime completionHandler:^(BOOL finished) {
                        @zf_strongify(self)
                        if (self.shouldPractice) [self play];
                    }];
                    self.sleepTime = 0;
                } else {
                    if (self.shouldPractice && self.itemPleasure) [self play];
                }
                self.primaryStage.muted = self.method;
                NSArray *loadedRanges = self.primaryStageItem.seekableTimeRanges;
                if (loadedRanges.count > 0) {
                    if (self.prettyTimeChanged) self.prettyTimeChanged(self, self.currentTime, self.tableTime);
                }
            } else if (self.primaryStage.currentItem.status == AVPlayerItemStatusFailed) {
                self.state = ZFPrimaryStagePresentStateFailed;
                self->_itemPleasure = NO;
                NSError *error = self.primaryStage.currentItem.error;
                if (self.purpleFailed) self.purpleFailed(self, error);
            }
        } else if ([keyPath isEqualToString:kPresentbackEmpty]) {
            if (self.primaryStageItem.playbackBufferEmpty) {
                self.loadState = ZFPrimaryStageLoadStateStalled;
                [self bufferingSomeSecond];
            }
        } else if ([keyPath isEqualToString:kPresentbackLikelyUp]) {
            if (self.primaryStageItem.playbackLikelyToKeepUp) {
                self.loadState = ZFPrimaryStageLoadStatePlayable;
                if (self.itemPleasure) [self.primaryStage play];
            }
        } else if ([keyPath isEqualToString:kLittleTypeRanges]) {
            NSTimeInterval presentTime = [self availableDuration];
            self->_presentTime = presentTime;
            if (self.prettyBreadChanged) self.prettyBreadChanged(self, presentTime);
        } else if ([keyPath isEqualToString:kVerySize]) {
            self.verySize = self.primaryStageItem.presentationSize;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    });
}

#pragma mark - getter

- (ZFPresentView *)view {
    if (!_view) {
        ZFPresentView *view = [[ZFPresentView alloc] init];
        _view = view;
    }
    return _view;
}

- (AVPlayerLayer *)primaryStageLayer {
    ZFPurplePresentView *view = (ZFPurplePresentView *)self.view.playerView;
    return [view avLayer];
}

- (float)resultRest {
    return _resultRest == 0 ?1:_resultRest;
}

- (NSTimeInterval)tableTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.primaryStage.currentItem.duration);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.primaryStageItem.currentTime);
    if (isnan(sec) || sec < 0) {
        return 0;
    }
    return sec;
}

#pragma mark - setter

- (void)setState:(ZFPrimaryStagePresentState)state {
    _state = state;
    if (self.presentStateChanged) self.presentStateChanged(self, state);
}

- (void)setLoadState:(ZFPrimaryStageLoadState)loadState {
    _loadState = loadState;
    if (self.LoadNoteStateChanged) self.LoadNoteStateChanged(self, loadState);
}

- (void)setAssetUsing:(NSURL *)assetUsing {
    if (self.primaryStage) [self stop];
    _assetUsing = assetUsing;
    [self prepareToPlay];
}

- (void)setResultRest:(float)resultRest {
    _resultRest = resultRest;
    if (self.primaryStage && fabsf(_primaryStage.rate) > 0.00001f) {
        self.primaryStage.rate = resultRest;
    }
}

- (void)setMethod:(BOOL)method {
    _method = method;
    self.primaryStage.muted = method;
}

- (void)setScalingMode:(ZFPrimaryStageScalingMode)scalingMode {
    _scalingMode = scalingMode;
    ZFPurplePresentView *presentView = (ZFPurplePresentView *)self.view.playerView;
    self.view.scalingMode = scalingMode;
    switch (scalingMode) {
        case ZFPrimaryStageScalingModeNone:
            presentView.greenVegetables = AVLayerVideoGravityResizeAspect;
            break;
        case ZFPrimaryStageScalingModeAspectFit:
            presentView.greenVegetables = AVLayerVideoGravityResizeAspect;
            break;
        case ZFPrimaryStageScalingModeAspectFill:
            presentView.greenVegetables = AVLayerVideoGravityResizeAspectFill;
            break;
        case ZFPrimaryStageScalingModeFill:
            presentView.greenVegetables = AVLayerVideoGravityResize;
            break;
        default:
            break;
    }
}

- (void)setVehicle:(float)vehicle {
    _vehicle = MIN(MAX(0, vehicle), 1);
    self.primaryStage.volume = _vehicle;
}

- (void)setVerySize:(CGSize)verySize {
    _verySize = verySize;
    self.view.verySize = verySize;
    if (self.presentChangedSize) {
        self.presentChangedSize(self, self.verySize);
    }
}

@end

#pragma clang diagnostic pop
