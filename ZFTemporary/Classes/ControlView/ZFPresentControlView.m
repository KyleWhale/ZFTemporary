

#import "ZFPresentControlView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+ZFFrame.h"
#import "ZFSliderView.h"
#import "ZFUtilities.h"
#import "UIImageView+ZFCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZFVehicleBrightnessView.h"
#import "ZFPrimaryConst.h"

@interface ZFPresentControlView () <ZFSliderViewDelegate>
@property (nonatomic, strong) ZFPortraitControlView *portraitControlView;
@property (nonatomic, strong) ZFLightControlView *lightControlView;
@property (nonatomic, strong) ZFSpeedLaughView *laughView;
@property (nonatomic, strong) UIView *fastView;
@property (nonatomic, strong) ZFSliderView *fastProperView;
@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIButton *errorButton;
@property (nonatomic, strong) ZFSliderView *bottomPresentView;
@property (nonatomic, assign, getter=isShowing) BOOL showing;
@property (nonatomic, assign, getter=isPresentEnd) BOOL presentEnd;

@property (nonatomic, assign) BOOL controlViewAppeared;

@property (nonatomic, assign) NSTimeInterval sumTime;

@property (nonatomic, strong) dispatch_block_t afterBlock;

@property (nonatomic, strong) ZFSmallFloatControlView *floatControlView;

@property (nonatomic, strong) ZFVehicleBrightnessView *vehicleView;

@property (nonatomic, strong) UIImageView *bgImgView;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation ZFPresentControlView
@synthesize primaryPretty = _primaryPretty;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addAllSubViews];
        self.lightControlView.hidden = YES;
        self.floatControlView.hidden = YES;
        self.tempTp = YES;
        self.primaryViewShow = YES;
        self.horizontalPanShowControlView = YES;
        self.fadeTime = 0.25;
        self.hiddenTime = 2.5;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(vehicleChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.zf_width;
    CGFloat min_view_h = self.zf_height;

    self.portraitControlView.frame = self.bounds;
    self.lightControlView.frame = self.bounds;
    self.floatControlView.frame = self.bounds;
    self.coverImageView.frame = self.bounds;
    self.bgImgView.frame = self.bounds;
    self.emptyView.frame = self.bounds;
    
    min_w = 80;
    min_h = 80;
    self.laughView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.laughView.zf_centerX = self.zf_centerX;
    self.laughView.zf_centerY = self.zf_centerY + 10;
    
    min_w = 250;
    min_h = 40;
    self.errorButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.errorButton.center = self.center;
    
    min_w = 140;
    min_h = 80;
    self.fastView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.fastView.center = self.center;
    
    min_w = 32;
    min_x = (self.fastView.zf_width - min_w) / 2;
    min_y = 5;
    min_h = 32;
    self.firstImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = self.firstImageView.zf_bottom + 2;
    min_w = self.fastView.zf_width;
    min_h = 20;
    self.firstLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 12;
    min_y = self.firstLabel.zf_bottom + 5;
    min_w = self.fastView.zf_width - 2 * min_x;
    min_h = 10;
    self.fastProperView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = min_view_h - 1;
    min_w = min_view_w;
    min_h = 1;
    self.bottomPresentView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = iPhoneX ? 54 : 30;
    min_w = 170;
    min_h = 35;
    self.vehicleView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.vehicleView.zf_centerX = self.zf_centerX;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self cancelAutoView1];
}

- (void)addAllSubViews {
    [self addSubview:self.portraitControlView];
    [self addSubview:self.lightControlView];
    [self addSubview:self.floatControlView];
    [self addSubview:self.laughView];
    [self addSubview:self.errorButton];
    [self addSubview:self.fastView];
    [self.fastView addSubview:self.firstImageView];
    [self.fastView addSubview:self.firstLabel];
    [self.fastView addSubview:self.fastProperView];
    [self addSubview:self.bottomPresentView];
    [self addSubview:self.vehicleView];
}

- (void)primaryStateChangeView {
    self.controlViewAppeared = YES;
    [self cancelAutoView1];
    @zf_weakify(self)
    self.afterBlock = dispatch_block_create(0, ^{
        @zf_strongify(self)
        [self hideControlViewWithAnimated:YES];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.hiddenTime * NSEC_PER_SEC)), dispatch_get_main_queue(),self.afterBlock);
}

- (void)cancelAutoView1 {
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
}

- (void)hideControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = NO;
    if (self.controlViewAppearedCallback) {
        self.controlViewAppearedCallback(NO);
    }
    [UIView animateWithDuration:animated ? self.fadeTime : 0 animations:^{
        if (self.primaryPretty.isFullScreen) {
            [self.lightControlView hideControlView];
        } else {
            if (!self.primaryPretty.smallFloatViewShow) {
                [self.portraitControlView hideControlView];
            }
        }
    } completion:^(BOOL finished) {
        self.bottomPresentView.hidden = NO;
    }];
}

- (void)showControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = YES;
    if (self.controlViewAppearedCallback) {
        self.controlViewAppearedCallback(YES);
    }
    [self primaryStateChangeView];
    [UIView animateWithDuration:animated ? self.fadeTime : 0 animations:^{
        if (self.primaryPretty.isFullScreen) {
            [self.lightControlView showControlView];
        } else {
            if (!self.primaryPretty.smallFloatViewShow) {
                [self.portraitControlView showControlView];
            }
        }
    } completion:^(BOOL finished) {
        self.bottomPresentView.hidden = YES;
    }];
}

- (void)vehicleChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *reasonstr = userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    if ([reasonstr isEqualToString:@"ExplicitVolumeChange"]) {
        float vehicle = [ userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        if (self.primaryPretty.isFullScreen) {
            [self.vehicleView updatePercent:vehicle withVehicleType:ZFVehicleTypeVehicle];
        } else {
            [self.vehicleView addShortVehicleView];
        }
    }
}

#pragma mark - Public Method

- (void)resetControlledView {
    [self.portraitControlView resetControlledView];
    [self.lightControlView resetControlledView];
    [self cancelAutoView1];
    self.bottomPresentView.value = 0;
    self.bottomPresentView.basketValue = 0;
    self.floatControlView.hidden = YES;
    self.errorButton.hidden = YES;
    self.vehicleView.hidden = YES;
    self.portraitControlView.hidden = self.primaryPretty.isFullScreen;
    self.lightControlView.hidden = !self.primaryPretty.isFullScreen;
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl fulfilledMode:(ZFFineScheduleMode)fulfilledMode {
    UIImage *placeholder = [ZFUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:self.bgImgView.bounds.size];
    [self showTitle:title coverURLString:coverUrl placeholderImage:placeholder fulfilledMode:fulfilledMode];
}

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl placeholderImage:(UIImage *)placeholder fulfilledMode:(ZFFineScheduleMode)fulfilledMode {
    [self resetControlledView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fulfilledMode:fulfilledMode];
    [self.lightControlView showTitle:title fulfilledMode:fulfilledMode];
    [self.primaryPretty.periodManager.view.coverImageView setImageWithURLString:coverUrl placeholder:placeholder];
    [self.bgImgView setImageWithURLString:coverUrl placeholder:placeholder];
    if (self.prepareShowView) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

- (void)showTitle:(NSString *)title coverImage:(UIImage *)image fulfilledMode:(ZFFineScheduleMode)fulfilledMode {
    [self resetControlledView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fulfilledMode:fulfilledMode];
    [self.lightControlView showTitle:title fulfilledMode:fulfilledMode];
    self.coverImageView.image = image;
    self.bgImgView.image = image;
    if (self.prepareShowView) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

#pragma mark - ZFPresentControlViewDelegate

- (BOOL)gestureTriggerCondition:(ZFPresentGestureControl *)gestureControl gestureType:(ZFPrimaryStageGestureType)gestureType gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer touch:(nonnull UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (self.primaryPretty.smallFloatViewShow && !self.primaryPretty.isFullScreen && gestureType != ZFPrimaryStageGestureTypeSingleTap) {
        return NO;
    }
    if (self.primaryPretty.isFullScreen) {
        if (!self.customDisablePanMovingDirection) {
            self.primaryPretty.disablePanMovingDirection = ZFPrimaryStageDisablePanMovingDirectionNone;
        }
        return [self.lightControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    } else {
        if (!self.customDisablePanMovingDirection) {
            if (self.primaryPretty.scrollView) {
                self.primaryPretty.disablePanMovingDirection = ZFPrimaryStageDisablePanMovingDirectionVertical;
            } else {
                self.primaryPretty.disablePanMovingDirection = ZFPrimaryStageDisablePanMovingDirectionNone;
            }
        }
        return [self.portraitControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    }
}

- (void)gestureSingleTapped:(ZFPresentGestureControl *)gestureControl {
    if (!self.primaryPretty) return;
    if (self.primaryPretty.smallFloatViewShow && !self.primaryPretty.isFullScreen) {
        [self.primaryPretty enterFineExample:YES animated:YES];
    } else {
        if (self.controlViewAppeared) {
            [self hideControlViewWithAnimated:YES];
        } else {
            [self showControlViewWithAnimated:YES];
        }
    }
}

- (void)gestureDoubleTapped:(ZFPresentGestureControl *)gestureControl {
    if (self.primaryPretty.isFullScreen) {
        [self.lightControlView pointPleaseClick];
    } else {
        [self.portraitControlView practiceButtonClick];
    }
}

- (void)gestureBeganPan:(ZFPresentGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    if (direction == ZFPanDirectionHorizontal) {
        self.sumTime = self.primaryPretty.currentTime;
    }
}

- (void)gestureChangedPan:(ZFPresentGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location withVelocity:(CGPoint)velocity {
    if (direction == ZFPanDirectionHorizontal) {
        self.sumTime += velocity.x / 200;
        NSTimeInterval interval = self.primaryPretty.tableTime;
        if (interval == 0) return;
        if (self.sumTime > interval) self.sumTime = interval;
        if (self.sumTime < 0) self.sumTime = 0;
        BOOL style = NO;
        if (velocity.x > 0) style = YES;
        if (velocity.x < 0) style = NO;
        if (velocity.x == 0) return;
        [self sliderValueChangingValue:self.sumTime/interval isForward:style];
    } else if (direction == ZFPanDirectionVertical) {
        if (location == ZFPanLocationLeft) {
            self.primaryPretty.brightness -= (velocity.y) / 10000;
            [self.vehicleView updatePercent:self.primaryPretty.brightness withVehicleType:ZFVehicleTypeumeBrightness];
        } else if (location == ZFPanLocationRight) {
            self.primaryPretty.vehicle -= (velocity.y) / 10000;
            if (self.primaryPretty.isFullScreen) {
                [self.vehicleView updatePercent:self.primaryPretty.vehicle withVehicleType:ZFVehicleTypeVehicle];
            }
        }
    }
}

- (void)gestureEndedPan:(ZFPresentGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    @zf_weakify(self)
    if (direction == ZFPanDirectionHorizontal && self.sumTime >= 0 && self.primaryPretty.tableTime > 0) {
        [self.primaryPretty seekToTime:self.sumTime completionHandler:^(BOOL finished) {
            @zf_strongify(self)
            [self.portraitControlView sliderChangeEnded];
            [self.lightControlView sliderChangeEnded];
            self.bottomPresentView.itemDragging = NO;
            if (self.controlViewAppeared) {
                [self primaryStateChangeView];
            }
        }];
        if (self.tempTp) {
            [self.primaryPretty.periodManager play];
        }
        self.sumTime = 0;
    }
}

- (void)gesturePinched:(ZFPresentGestureControl *)gestureControl scale:(float)scale {
    if (scale > 1) {
        self.primaryPretty.periodManager.scalingMode = ZFPrimaryStageScalingModeAspectFill;
    } else {
        self.primaryPretty.periodManager.scalingMode = ZFPrimaryStageScalingModeAspectFit;
    }
}

- (void)longPressed:(ZFPresentGestureControl *)gestureControl state:(ZFLongPressGestureRecognizerState)state {
    
}

- (void)veryPractice:(ZFPresentController *)practiceScreen prepareToPlay:(NSURL *)assetUsing {
    [self hideControlViewWithAnimated:NO];
}

- (void)veryPractice:(ZFPresentController *)practiceScreen presentPoliteStateChanged:(ZFPrimaryStagePresentState)state {
    if (state == ZFPrimaryStagePresentStatePolite) {
        [self.portraitControlView practiceSelected:YES];
        [self.lightControlView practiceSelected:YES];
        self.errorButton.hidden = YES;
        if (practiceScreen.periodManager.loadState == ZFPrimaryStageLoadStateStalled && !self.showLoading) {
            [self.laughView startAnimating];
        } else if ((practiceScreen.periodManager.loadState == ZFPrimaryStageLoadStateStalled || practiceScreen.periodManager.loadState == ZFPrimaryStageLoadStatePrepare) && self.showLoading) {
            [self.laughView startAnimating];
        }
    } else if (state == ZFPrimaryStagePresentStatePattern) {
        [self.portraitControlView practiceSelected:NO];
        [self.lightControlView practiceSelected:NO];
        [self.laughView stopAnimating];
        self.errorButton.hidden = YES;
    } else if (state == ZFPrimaryStagePresentStateFailed) {
        self.errorButton.hidden = NO;
        [self.laughView stopAnimating];
    }
}

- (void)veryPractice:(ZFPresentController *)practiceScreen stateLoadChanged:(ZFPrimaryStageLoadState)state {
    if (state == ZFPrimaryStageLoadStatePrepare) {
        self.coverImageView.hidden = NO;
        [self.portraitControlView practiceSelected:practiceScreen.periodManager.shouldPractice];
        [self.lightControlView practiceSelected:practiceScreen.periodManager.shouldPractice];
    } else if (state == ZFPrimaryStageLoadStatePlaythroughOK || state == ZFPrimaryStageLoadStatePlayable) {
        self.coverImageView.hidden = YES;
        if (self.primaryViewShow) {
            self.emptyView.hidden = NO;
        } else {
            self.emptyView.hidden = YES;
            self.primaryPretty.periodManager.view.backgroundColor = [UIColor blackColor];
        }
    }
    if (state == ZFPrimaryStageLoadStateStalled && practiceScreen.periodManager.itemPleasure && !self.showLoading) {
        [self.laughView startAnimating];
    } else if ((state == ZFPrimaryStageLoadStateStalled || state == ZFPrimaryStageLoadStatePrepare) && practiceScreen.periodManager.itemPleasure && self.showLoading) {
        [self.laughView startAnimating];
    } else {
        [self.laughView stopAnimating];
    }
}

- (void)veryPractice:(ZFPresentController *)practiceScreen currentTime:(NSTimeInterval)currentTime tableTime:(NSTimeInterval)tableTime {
    [self.portraitControlView veryPractice:practiceScreen currentTime:currentTime tableTime:tableTime];
    [self.lightControlView veryPractice:practiceScreen currentTime:currentTime tableTime:tableTime];
    if (!self.bottomPresentView.itemDragging) {
        self.bottomPresentView.value = practiceScreen.percent;
    }
}

- (void)veryPractice:(ZFPresentController *)practiceScreen presentTime:(NSTimeInterval)presentTime {
    [self.portraitControlView veryPractice:practiceScreen presentTime:presentTime];
    [self.lightControlView veryPractice:practiceScreen presentTime:presentTime];
    self.bottomPresentView.basketValue = practiceScreen.bufferProfile;
}

- (void)veryPractice:(ZFPresentController *)practiceScreen presentChangedSize:(CGSize)size {
    [self.lightControlView veryPractice:practiceScreen presentChangedSize:size];
}

- (void)veryPractice:(ZFPresentController *)practiceScreen orientationWillChange:(ZFOrientationObserver *)observer {
    self.portraitControlView.hidden = observer.isFullScreen;
    self.lightControlView.hidden = !observer.isFullScreen;
    if (practiceScreen.smallFloatViewShow) {
        self.floatControlView.hidden = observer.isFullScreen;
        self.portraitControlView.hidden = YES;
        if (observer.isFullScreen) {
            self.controlViewAppeared = NO;
            [self cancelAutoView1];
        }
    }
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
    
    if (observer.isFullScreen) {
        [self.vehicleView removeShortVehicleView];
    } else {
        [self.vehicleView addShortVehicleView];
    }
    [self.lightControlView veryPractice:practiceScreen orientationWillChange:observer];
}

- (void)lockedVeryPractice:(ZFPresentController *)practiceScreen practiced:(BOOL)locked {
    [self showControlViewWithAnimated:YES];
}

- (void)primaryStageDidAppearInScrollView:(ZFPresentController *)practiceScreen {
    if (!self.primaryPretty.stopWhileNotVisible && !practiceScreen.isFullScreen) {
        self.floatControlView.hidden = YES;
        self.portraitControlView.hidden = NO;
    }
}

- (void)primaryStageDidDisappearInScrollView:(ZFPresentController *)practiceScreen {
    if (!self.primaryPretty.stopWhileNotVisible && !practiceScreen.isFullScreen) {
        self.floatControlView.hidden = NO;
        self.portraitControlView.hidden = YES;
    }
}

- (void)veryPractice:(ZFPresentController *)practiceScreen floatViewShow:(BOOL)show {
    self.floatControlView.hidden = !show;
    self.portraitControlView.hidden = show;
}

#pragma mark - Private Method

- (void)sliderValueChangingValue:(CGFloat)value isForward:(BOOL)forward {
    if (self.horizontalPanShowControlView) {
        [self showControlViewWithAnimated:NO];
        [self cancelAutoView1];
    }
    
    self.fastProperView.value = value;
    self.fastView.hidden = NO;
    self.fastView.alpha = 1;
    if (forward) {
        self.firstImageView.image = ZFPrimaryStage_Image(@"temp_ff");
    } else {
        self.firstImageView.image = ZFPrimaryStage_Image(@"temp_fb");
    }
    NSString *draggedTime = [ZFUtilities convertTimeSecond:self.primaryPretty.tableTime*value];
    NSString *tableTime = [ZFUtilities convertTimeSecond:self.primaryPretty.tableTime];
    self.firstLabel.text = [NSString stringWithFormat:@"%@ / %@",draggedTime,tableTime];
    [self.portraitControlView sliderValueChanged:value currentTimeString:draggedTime];
    [self.lightControlView sliderValueChanged:value currentTimeString:draggedTime];
    self.bottomPresentView.itemDragging = YES;
    self.bottomPresentView.value = value;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFastView) object:nil];
    [self performSelector:@selector(hideFastView) withObject:nil afterDelay:0.1];
    
    if (self.firstViewAnimated) {
        [UIView animateWithDuration:0.4 animations:^{
            self.fastView.transform = CGAffineTransformMakeTranslation(forward?8:-8, 0);
        }];
    }
}

- (void)hideFastView {
    [UIView animateWithDuration:0.4 animations:^{
        self.fastView.transform = CGAffineTransformIdentity;
        self.fastView.alpha = 0;
    } completion:^(BOOL finished) {
        self.fastView.hidden = YES;
    }];
}

- (void)errorButtonClick:(UIButton *)sender {
    [self.primaryPretty.periodManager reloadPresent];
}

#pragma mark - setter

- (void)setPrimaryPretty:(ZFPresentController *)player {
    _primaryPretty = player;
    self.lightControlView.primaryStage = player;
    self.portraitControlView.player = player;
    [player.periodManager.view insertSubview:self.bgImgView atIndex:0];
    [self.bgImgView addSubview:self.emptyView];
    self.bgImgView.frame = player.periodManager.view.bounds;
    self.bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.emptyView.frame = self.bgImgView.bounds;
}

- (void)setTempTp:(BOOL)tempTp {
    _tempTp = tempTp;
    self.portraitControlView.tempTp = tempTp;
    self.lightControlView.tempTp = tempTp;
}

- (void)setPrimaryViewShow:(BOOL)show {
    _primaryViewShow = show;
    if (show) {
        self.bgImgView.hidden = NO;
    } else {
        self.bgImgView.hidden = YES;
    }
}

- (void)setFulfilledMode:(ZFFineScheduleMode)fulfilledMode {
    _fulfilledMode = fulfilledMode;
    self.portraitControlView.fulfilledMode = fulfilledMode;
    self.lightControlView.fulfilledMode = fulfilledMode;
    self.primaryPretty.orientationObserver.fulfilledMode = fulfilledMode;
}

- (void)setShowCustomStatusBar:(BOOL)showCustomStatusBar {
    _showCustomStatusBar = showCustomStatusBar;
    self.lightControlView.showCustomStatusBar = showCustomStatusBar;
}

#pragma mark - getter

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.userInteractionEnabled = YES;
    }
    return _bgImgView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *var_blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _emptyView = [[UIVisualEffectView alloc] initWithEffect:var_blur];
        } else {
            UIToolbar *view = [[UIToolbar alloc] init];
            view.barStyle = UIBarStyleBlackTranslucent;
            _emptyView = view;
        }
    }
    return _emptyView;
}

- (ZFPortraitControlView *)portraitControlView {
    if (!_portraitControlView) {
        @zf_weakify(self)
        _portraitControlView = [[ZFPortraitControlView alloc] init];
        _portraitControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
            @zf_strongify(self)
            NSString *draggedTime = [ZFUtilities convertTimeSecond:self.primaryPretty.tableTime*value];
            [self.lightControlView sliderValueChanged:value currentTimeString:draggedTime];
            self.fastProperView.value = value;
            self.bottomPresentView.itemDragging = YES;
            self.bottomPresentView.value = value;
            [self cancelAutoView1];
        };
        _portraitControlView.sliderValueChanged = ^(CGFloat value) {
            @zf_strongify(self)
            [self.lightControlView sliderChangeEnded];
            self.fastProperView.value = value;
            self.bottomPresentView.itemDragging = NO;
            self.bottomPresentView.value = value;
            [self primaryStateChangeView];
        };
    }
    return _portraitControlView;
}

- (ZFLightControlView *)lightControlView {
    if (!_lightControlView) {
        @zf_weakify(self)
        _lightControlView = [[ZFLightControlView alloc] init];
        _lightControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
            @zf_strongify(self)
            NSString *draggedTime = [ZFUtilities convertTimeSecond:self.primaryPretty.tableTime*value];
            [self.portraitControlView sliderValueChanged:value currentTimeString:draggedTime];
            self.fastProperView.value = value;
            self.bottomPresentView.itemDragging = YES;
            self.bottomPresentView.value = value;
            [self cancelAutoView1];
        };
        _lightControlView.sliderValueChanged = ^(CGFloat value) {
            @zf_strongify(self)
            [self.portraitControlView sliderChangeEnded];
            self.fastProperView.value = value;
            self.bottomPresentView.itemDragging = NO;
            self.bottomPresentView.value = value;
            [self primaryStateChangeView];
        };
    }
    return _lightControlView;
}

- (ZFSpeedLaughView *)laughView {
    if (!_laughView) {
        _laughView = [[ZFSpeedLaughView alloc] init];
    }
    return _laughView;
}

- (UIView *)fastView {
    if (!_fastView) {
        _fastView = [[UIView alloc] init];
        _fastView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _fastView.layer.cornerRadius = 4;
        _fastView.layer.masksToBounds = YES;
        _fastView.hidden = YES;
    }
    return _fastView;
}

- (UIImageView *)firstImageView {
    if (!_firstImageView) {
        _firstImageView = [[UIImageView alloc] init];
    }
    return _firstImageView;
}

- (UILabel *)firstLabel {
    if (!_firstLabel) {
        _firstLabel = [[UILabel alloc] init];
        _firstLabel.textColor = [UIColor whiteColor];
        _firstLabel.textAlignment = NSTextAlignmentCenter;
        _firstLabel.font = [UIFont systemFontOfSize:14.0];
        _firstLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _firstLabel;
}

- (ZFSliderView *)fastProperView {
    if (!_fastProperView) {
        _fastProperView = [[ZFSliderView alloc] init];
        _fastProperView.maximumTrackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        _fastProperView.minimumTrackTintColor = [UIColor whiteColor];
        _fastProperView.sliderHeight = 2;
        _fastProperView.hideSliderBlock = NO;
    }
    return _fastProperView;
}

- (UIButton *)errorButton {
    if (!_errorButton) {
        _errorButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_errorButton setTitle:@"Net work error. Please try again." forState:UIControlStateNormal];
        [_errorButton addTarget:self action:@selector(errorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_errorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _errorButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _errorButton.titleLabel.numberOfLines = 0;
        _errorButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _errorButton.hidden = YES;
    }
    return _errorButton;
}

- (ZFSliderView *)bottomPresentView {
    if (!_bottomPresentView) {
        _bottomPresentView = [[ZFSliderView alloc] init];
        _bottomPresentView.maximumTrackTintColor = [UIColor clearColor];
        _bottomPresentView.minimumTrackTintColor = [UIColor whiteColor];
        _bottomPresentView.boardTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomPresentView.sliderHeight = 1;
        _bottomPresentView.hideSliderBlock = NO;
    }
    return _bottomPresentView;
}

- (ZFSmallFloatControlView *)floatControlView {
    if (!_floatControlView) {
        _floatControlView = [[ZFSmallFloatControlView alloc] init];
        @zf_weakify(self)
        _floatControlView.closeClickCallback = ^{
            @zf_strongify(self)
            if (self.primaryPretty.containerType == ZFPrimaryStageContainerTypeCell) {
                [self.primaryPretty stopCurrentCell];
            } else if (self.primaryPretty.containerType == ZFPrimaryStageContainerTypeView) {
                [self.primaryPretty stopCurrentView];
            }
            [self resetControlledView];
        };
    }
    return _floatControlView;
}

- (ZFVehicleBrightnessView *)vehicleView {
    if (!_vehicleView) {
        _vehicleView = [[ZFVehicleBrightnessView alloc] init];
        _vehicleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _vehicleView.hidden = YES;
    }
    return _vehicleView;
}

- (void)setBackBtnClickCallback:(void (^)(void))backBtnClickCallback {
    _backBtnClickCallback = [backBtnClickCallback copy];
    self.lightControlView.backBtnClickCallback = _backBtnClickCallback;
}

@end
