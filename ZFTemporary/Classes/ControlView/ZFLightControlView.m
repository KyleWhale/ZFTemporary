

#import "ZFLightControlView.h"
#import "UIView+ZFFrame.h"
#import "ZFUtilities.h"
#import "ZFPresentStatusBar.h"
#import "ZFPrimaryConst.h"
#import "ZFAdView.h"
#import "ZFAdManager.h"

@interface ZFLightControlView () <ZFSliderViewDelegate>

@property (nonatomic, strong) ZFPresentStatusBar *statusBarView;
@property (nonatomic, strong) UIView *topToolView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIView *bottomToolView;

@property (nonatomic, strong) UIButton *pointPleaseBtn;

@property (nonatomic, strong) UILabel *currentTimeLabel;

@property (nonatomic, strong) ZFSliderView *slider;
@property (nonatomic, strong) UILabel *tableTimeLabel;

@property (nonatomic, strong) UIButton *lockBtn;

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL hasAd;
@property (nonatomic, strong) ZFAdView *adviseView;

@property (nonatomic, assign) BOOL showBanner;

@end

@implementation ZFLightControlView

- (ZFAdView *)adviseView{
    if(!_adviseView){
        _adviseView = [ZFAdManager shared].bannerView;
        _adviseView.frame = CGRectMake((self.bounds.size.width - 320)/2.0, 0, 320, 50);
        _adviseView.alpha = 0;
        __weak typeof(self) weakSelf = self;
        _adviseView.block = ^(id  _Nullable data) {
            if(![ZFAdManager.shared.ad sub] && !weakSelf.showBanner){
                weakSelf.adviseView.alpha = 1;
                weakSelf.showBanner = YES;
                [weakSelf showAutoClose];
            }
        };
        _adviseView.backgroundColor = UIColorFromHex(0x23252A);
    }
    return _adviseView;
}

- (void)showAutoClose{
    int closeTime = 5;
    if(ZFAdManager.shared.ad.close){
        closeTime = ZFAdManager.shared.ad.close.intValue;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(closeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(![ZFAdManager.shared.ad sub]){
            self.adviseView.alpha = 0;
            [self contiuneAutoShow];
        }
    });
}

- (void)contiuneAutoShow{
    int time = 180;
    if(ZFAdManager.shared.ad.secs){
        time = ZFAdManager.shared.ad.secs.intValue;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(![ZFAdManager.shared.ad sub]){
            self.adviseView.alpha = 1;
            [self showAutoClose];
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if(!hidden){
        if(![ZFAdManager.shared.ad sub] && !self.hasAd){
            [self addSubview:self.adviseView];
            [self.adviseView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(320, 50));
                make.centerX.mas_equalTo(0);
                make.top.mas_equalTo(0);
            }];
            self.hasAd = YES;
        }
    }
}

- (UIStackView *)stackView{
    if(!_stackView){
        _stackView = UIStackView.new;
        _stackView.spacing = 10;
    }
    return _stackView;
}

- (UIStackView *)leftStackView{
    if(!_leftStackView){
        _leftStackView = UIStackView.new;
        _leftStackView.spacing = 10;
    }
    return _leftStackView;
}

- (UIStackView *)topStasckView{
    if(!_topStasckView){
        _topStasckView = UIStackView.new;
        _topStasckView.spacing = 10;
    }
    return _topStasckView;
}

- (void)episodesAction{
    if (ZFAdManager.shared.ad.eps) {
        ZFAdManager.shared.ad.eps();
    }
}

- (void)adAction{
    if (ZFAdManager.shared.ad.remove) {
        ZFAdManager.shared.ad.remove();
    }
}

- (void)ccAction{
    if (ZFAdManager.shared.ad.subtitle) {
        ZFAdManager.shared.ad.subtitle();
    }
}

- (void)shareAction{
    if (ZFAdManager.shared.ad.share) {
        ZFAdManager.shared.ad.share();
    }
}

- (void)toupingAction{
    if (ZFAdManager.shared.ad.cast) {
        ZFAdManager.shared.ad.cast();
    }
}

- (void)collectAction:(UIButton*)button{
    if (ZFAdManager.shared.ad.collect) {
        ZFAdManager.shared.ad.collect();
    }
}

- (void)fullAction{
    [self.primaryStage enterFineExample:NO animated:YES];
}

- (UIButton *)episodes{
    if(!_episodes){
        _episodes = [UIButton buttonWithType:UIButtonTypeCustom];
        [_episodes setImage:ZFPrimaryStage_Image(@"temp_e") forState:UIControlStateNormal];
        _episodes.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        _episodes.hidden = YES;
        [_episodes addTarget:self action:@selector(episodesAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _episodes;
}

- (UIButton *)ccBTN{
    if(!_ccBTN){
        _ccBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ccBTN setImage:ZFPrimaryStage_Image(@"temp_mc") forState:UIControlStateNormal];
        _ccBTN.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [_ccBTN addTarget:self action:@selector(ccAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ccBTN;
}

- (UIButton *)adBTN{
    if(!_adBTN){
        _adBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        NSMutableString *string = [NSMutableString string];
        NSArray *array = @[@74, @111, @105, @110, @32, @86, @73, @80];
        for (NSNumber *number in array) {
            [string appendString:[NSString stringWithFormat:@"%c", number.intValue]];
        }
        [_adBTN setTitle:string forState:UIControlStateNormal];
        [_adBTN setTitleColor:UIColorFromHex(0x916820) forState:UIControlStateNormal];
        _adBTN.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _adBTN.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        [_adBTN addTarget:self action:@selector(adAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adBTN;
}

- (UIButton *)shareBTN{
    if(!_shareBTN){
        _shareBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBTN setImage:ZFPrimaryStage_Image(@"temp_se") forState:UIControlStateNormal];
        _shareBTN.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [_shareBTN addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBTN;
}

- (UIButton *)fullBTN{
    if(!_fullBTN){
        _fullBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullBTN setImage:ZFPrimaryStage_Image(@"temp_fu") forState:UIControlStateNormal];
        _fullBTN.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [_fullBTN addTarget:self action:@selector(fullAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullBTN;
}

- (UIButton *)toupingBTN{
    if(!_toupingBTN){
        _toupingBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toupingBTN setImage:ZFPrimaryStage_Image(@"temp_tpg") forState:UIControlStateNormal];
        [_toupingBTN addTarget:self action:@selector(toupingAction) forControlEvents:UIControlEventTouchUpInside];
        _toupingBTN.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    }
    return _toupingBTN;
}

- (UIButton *)collectBTN{
    if(!_collectBTN){
        _collectBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectBTN setImage:ZFPrimaryStage_Image(@"temp_ca") forState:UIControlStateNormal];
        [_collectBTN setImage:ZFPrimaryStage_Image(@"temp_cas") forState:UIControlStateSelected];
        [_collectBTN addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
        _collectBTN.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    }
    return _collectBTN;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topToolView];
        [self.topToolView addSubview:self.statusBarView];
        [self.topToolView addSubview:self.backBtn];
        [self.topToolView addSubview:self.titleLabel];
        [self.topToolView addSubview:self.topStasckView];
        
        [self addSubview:self.bottomToolView];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.tableTimeLabel];
        [self.bottomToolView addSubview:self.leftStackView];
        [self.bottomToolView addSubview:self.stackView];
        
        [self addSubview:self.lockBtn];
        self.centerTool = UIStackView.new;
        self.centerTool.userInteractionEnabled = YES;
        self.centerTool.spacing = 120;
        [self addSubview:self.centerTool];
        [self.centerTool mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
        }];
        [self.centerTool addArrangedSubview:self.leftBTN];
        [self.centerTool addArrangedSubview:self.centerBTN];
        [self.centerTool addArrangedSubview:self.rightBTN];
        
        [self.topStasckView addArrangedSubview:self.adBTN];
        [self.topStasckView addArrangedSubview:self.toupingBTN];
        [self.topStasckView addArrangedSubview:self.collectBTN];
        [self.topStasckView addArrangedSubview:self.shareBTN];
        
        [self.stackView addArrangedSubview:self.episodes];
        [self.stackView addArrangedSubview:self.ccBTN];
        [self.stackView addArrangedSubview:self.fullBTN];
        
        [self.leftStackView addArrangedSubview:self.pointPleaseBtn];
        [self.leftStackView addArrangedSubview:self.nextSkip];
        
        [self makeSubViewsAction];
        [self resetControlledView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutControllerViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.adBTN.hidden = [ZFAdManager.shared.ad sub];
    
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    CGFloat min_margin = 9;
    
    min_x = 0;
    min_y = 0;
    min_w = min_view_w;
    min_h = 94;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = min_view_w;
    min_h = 20;
    self.statusBarView.frame = CGRectMake(min_x, min_y, min_w, min_h);

    min_x = 60;
    if (@available(iOS 13.0, *)) {
        if (self.showCustomStatusBar) {
            min_y = self.statusBarView.zf_bottom;
        } else {
            min_y = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 10 : (iPhoneX ? 40 : 20);
        }
    } else {
        min_y = (iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 10: (iPhoneX ? 40 : 20);
    }
    min_w = 40;
    min_h = 40;
    self.backBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    [self.topStasckView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60);
        make.centerY.equalTo(self.backBtn);
    }];
    [self.topStasckView layoutIfNeeded];
    self.adBTN.layer.cornerRadius = self.adBTN.frame.size.height / 2.0;
    self.adBTN.layer.masksToBounds = YES;
    self.adBTN.backgroundColor = UIColorFromHex(0xECCD6E);
    
    min_x = self.backBtn.zf_right + 5;
    min_y = 0;
    min_w = min_view_w - min_x - 15 - self.topStasckView.zf_width - 60;
    min_h = 30;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.titleLabel.zf_centerY = self.backBtn.zf_centerY;

    min_h = iPhoneX ? 100 : 88;
    min_x = 0;
    min_y = min_view_h - min_h - 10;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 55;
    min_y = 0;
    min_w = 62;
    min_h = 30;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.currentTimeLabel.zf_centerY = self.pointPleaseBtn.zf_centerY;
    
    min_w = 60;
    min_x = self.bottomToolView.zf_width - min_w - ((iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 44: min_margin) - 55;
    min_y = 0;
    min_h = 30;
    self.tableTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.tableTimeLabel.zf_centerY = self.pointPleaseBtn.zf_centerY;
    
    min_x = self.currentTimeLabel.zf_right + 4;
    min_y = 0;
    min_w = self.tableTimeLabel.zf_left - min_x - 4;
    min_h = 30;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.slider.zf_centerY = self.pointPleaseBtn.zf_centerY;
    
    [self.leftStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60);
        make.top.equalTo(self.currentTimeLabel.mas_bottom).offset(15);
    }];
    
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60);
        make.centerY.equalTo(self.leftStackView);
    }];
    
    min_x = 60;
    min_y = 0;
    min_w = 40;
    min_h = 40;
    self.lockBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.lockBtn.zf_centerY = self.zf_centerY;
    
    if (!self.isShow) {
        self.topToolView.zf_y = -self.topToolView.zf_height;
        self.bottomToolView.zf_y = self.zf_height;
        self.lockBtn.zf_left = iPhoneX ? -82: -47;
    } else {
        self.lockBtn.zf_left = 60;
        if (self.primaryStage.isLockedScreen) {
            self.topToolView.zf_y = -self.topToolView.zf_height;
            self.bottomToolView.zf_y = self.zf_height;
        } else {
            self.topToolView.zf_y = 0;
            self.bottomToolView.zf_y = self.zf_height - self.bottomToolView.zf_height;
        }
    }
}

- (void)makeSubViewsAction {
    [self.backBtn addTarget:self action:@selector(btnBackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.pointPleaseBtn addTarget:self action:@selector(makeButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.lockBtn addTarget:self action:@selector(lockButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *ta1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftBtnClickAction)];
    UITapGestureRecognizer *ta2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rightButtonClickAction)];
    [self.centerBTN addTarget:self action:@selector(makeButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftBTN addGestureRecognizer:ta1];
    [self.rightBTN addGestureRecognizer:ta2];
}

- (void)leftBtnClickAction{
    if (self.primaryStage.tableTime && self.primaryStage.currentTime >= 10) {
        @zf_weakify(self)
        [self.primaryStage seekToTime:self.primaryStage.currentTime - 10  completionHandler:^(BOOL finished) {
            @zf_strongify(self)
            if(self.controlBlock){
                self.controlBlock();
            }
            [self.primaryStage.periodManager play];
        }];
    }
    if (ZFAdManager.shared.ad.left) {
        ZFAdManager.shared.ad.left();
    }
}

- (void)rightButtonClickAction{
    if (self.primaryStage.tableTime) {
        @zf_weakify(self)
        [self.primaryStage seekToTime:self.primaryStage.currentTime + 10  completionHandler:^(BOOL finished) {
            @zf_strongify(self)
            if(self.controlBlock){
                self.controlBlock();
            }
            [self.primaryStage.periodManager play];
        }];
    }
    if (ZFAdManager.shared.ad.right) {
        ZFAdManager.shared.ad.right();
    }
}
#pragma mark - action

- (void)layoutControllerViews {
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)btnBackAction{
    [self backAction];
}

- (void)backBtnClickAction:(UIButton *)sender {
    self.lockBtn.selected = NO;
    self.primaryStage.lockedScreen = NO;
    self.lockBtn.selected = NO;
    if (self.primaryStage.orientationObserver.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait) {
        [self.primaryStage enterFineExample:NO animated:YES];
    }
    if (self.backBtnClickCallback) {
        self.backBtnClickCallback();
    }
}

- (void)backAction{
    self.lockBtn.selected = NO;
    self.primaryStage.lockedScreen = NO;
    self.lockBtn.selected = NO;
    if (self.primaryStage.orientationObserver.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait) {
        [self.primaryStage enterFineExample:NO animated:NO];
    }
}

- (void)makeButtonClickAction:(UIButton *)sender {
    [self pointPleaseClick];
}

- (void)pointPleaseClick {
    self.centerBTN.selected = !self.centerBTN.isSelected;;
    self.pointPleaseBtn.selected = !self.pointPleaseBtn.isSelected;
    self.pointPleaseBtn.isSelected? [self.primaryStage.periodManager play]: [self.primaryStage.periodManager pause];
    if(self.presentPoliteStateChanged) self.presentPoliteStateChanged(self.primaryStage.periodManager.state == ZFPrimaryStagePresentStatePolite);
}

- (void)practiceSelected:(BOOL)selected {
    self.pointPleaseBtn.selected = selected;
    self.centerBTN.selected = selected;
}

- (void)lockButtonClickAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.primaryStage.lockedScreen = sender.selected;
}

- (void)sliderTouchBegan:(float)value {
    self.slider.isdragging = YES;
}

- (void)sliderTouchEnded:(float)value {
    if (self.primaryStage.tableTime > 0) {
        self.slider.isdragging = YES;
        if (self.sliderValueChanging) self.sliderValueChanging(value, self.slider.isForward);
        @zf_weakify(self)
        [self.primaryStage seekToTime:self.primaryStage.tableTime*value completionHandler:^(BOOL finished) {
            @zf_strongify(self)
            self.slider.isdragging = NO;
            if (self.sliderValueChanged) self.sliderValueChanged(value);
            if (self.tempTp) {
                [self.primaryStage.periodManager play];
            }
        }];
    } else {
        self.slider.isdragging = NO;
        self.slider.value = 0;
    }
}

- (void)sliderValueChanged:(float)value {
    if (self.primaryStage.tableTime == 0) {
        self.slider.value = 0;
        return;
    }
    self.slider.isdragging = YES;
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.primaryStage.tableTime*value];
    self.currentTimeLabel.text = currentTimeString;
    if (self.sliderValueChanging) self.sliderValueChanging(value,self.slider.isForward);
}

- (void)sliderTapped:(float)value {
    [self sliderTouchEnded:value];
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.primaryStage.tableTime*value];
    self.currentTimeLabel.text = currentTimeString;
}

#pragma mark - public method

- (void)resetControlledView {
    self.slider.value                = 0;
    self.slider.basketValue          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.tableTimeLabel.text         = @"00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.pointPleaseBtn.selected     = YES;
    self.centerBTN.selected = YES;
    self.titleLabel.textLabel.text             = @"";
    self.topToolView.alpha           = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = NO;
    self.lockBtn.selected            = self.primaryStage.isLockedScreen;
}

- (void)showControlView {
    self.lockBtn.alpha               = 1;
    self.isShow                      = YES;
    if (self.primaryStage.isLockedScreen) {
        self.topToolView.zf_y        = -self.topToolView.zf_height;
        self.bottomToolView.zf_y     = self.zf_height;
    } else {
        self.topToolView.zf_y        = 0;
        self.bottomToolView.zf_y     = self.zf_height - self.bottomToolView.zf_height;
    }
    self.lockBtn.zf_left             = iPhoneX ? 50: 18;
    self.primaryStage.statusBarHidden      = NO;
    if (self.primaryStage.isLockedScreen) {
        self.topToolView.alpha       = 0;
        self.bottomToolView.alpha    = 0;
        self.centerTool.alpha = 0;
    } else {
        self.topToolView.alpha       = 1;
        self.bottomToolView.alpha    = 1;
        self.centerTool.alpha = 1;
    }
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.topToolView.zf_y            = -self.topToolView.zf_height;
    self.bottomToolView.zf_y         = self.zf_height;
    self.lockBtn.zf_left             = iPhoneX ? -82: -47;
    self.primaryStage.statusBarHidden      = YES;
    self.topToolView.alpha           = 0;
    self.bottomToolView.alpha        = 0;
    self.lockBtn.alpha               = 0;
    self.centerTool.alpha = 0;
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPrimaryStageGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    if (self.centerAd && (type != ZFPrimaryStageGestureTypeSingleTap && type != ZFPrimaryStageGestureTypeDoubleTap)) {
        return NO;
    }
    if (self.primaryStage.isLockedScreen && type != ZFPrimaryStageGestureTypeSingleTap) {
        return NO;
    }
    return YES;
}

- (void)veryPractice:(ZFPresentController *)practiceScreen presentChangedSize:(CGSize)size {
    self.lockBtn.hidden = self.primaryStage.orientationObserver.fulfilledMode == ZFFineScheduleModePortrait;
}

- (void)veryPractice:(ZFPresentController *)practiceScreen orientationWillChange:(ZFOrientationObserver *)observer {
    if (self.showCustomStatusBar) {
        if (self.hidden) {
            [self.statusBarView destoryTimer];
        } else {
            [self.statusBarView startTimer];
        }
    }
}

- (void)veryPractice:(ZFPresentController *)practiceScreen currentTime:(NSTimeInterval)currentTime tableTime:(NSTimeInterval)tableTime {
    if (!self.slider.isdragging) {
        NSString *currentTimeString = [ZFUtilities convertTimeSecond:currentTime];
        self.currentTimeLabel.text = currentTimeString;
        NSString *tableTimeString = [ZFUtilities convertTimeSecond:tableTime];
        self.tableTimeLabel.text = tableTimeString;
        self.slider.value = practiceScreen.percent;
    }
}

- (void)veryPractice:(ZFPresentController *)practiceScreen presentTime:(NSTimeInterval)presentTime {
    self.slider.basketValue = practiceScreen.bufferProfile;
}

- (void)showTitle:(NSString *)title fulfilledMode:(ZFFineScheduleMode)fulfilledMode {
    self.titleLabel.textLabel.text = title;
    self.primaryStage.orientationObserver.fulfilledMode = fulfilledMode;
    self.lockBtn.hidden = fulfilledMode == ZFFineScheduleModePortrait;
    [self.titleLabel startScrollIfNeed];
}

- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString {
    self.slider.value = value;
    self.currentTimeLabel.text = timeString;
    self.slider.isdragging = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

- (void)sliderChangeEnded {
    self.slider.isdragging = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderBtn.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - setter

- (void)setFulfilledMode:(ZFFineScheduleMode)fulfilledMode {
    _fulfilledMode = fulfilledMode;
    self.primaryStage.orientationObserver.fulfilledMode = fulfilledMode;
    self.lockBtn.hidden = fulfilledMode == ZFFineScheduleModePortrait;
}

- (void)setShowCustomStatusBar:(BOOL)showCustomStatusBar {
    _showCustomStatusBar = showCustomStatusBar;
    self.statusBarView.hidden = !showCustomStatusBar;
}

#pragma mark - getter

- (ZFPresentStatusBar *)statusBarView {
    if (!_statusBarView) {
        _statusBarView = [[ZFPresentStatusBar alloc] init];
        _statusBarView.hidden = YES;
    }
    return _statusBarView;
}

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
        UIImage *image = ZFPrimaryStage_Image(@"temp_ts");
        _topToolView.layer.contents = (id)image.CGImage;
    }
    return _topToolView;
}

- (UIButton *)leftBTN{
    if (!_leftBTN) {
        _leftBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBTN setImage:ZFPrimaryStage_Image(@"temp_ll") forState:UIControlStateNormal];
    }
    return _leftBTN;
}

- (UIButton *)rightBTN{
    if (!_rightBTN) {
        _rightBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBTN setImage:ZFPrimaryStage_Image(@"temp_lr") forState:UIControlStateNormal];
    }
    return _rightBTN;
}

- (UIButton *)centerBTN{
    if (!_centerBTN) {
        _centerBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerBTN setImage:ZFPrimaryStage_Image(@"temp_lp") forState:UIControlStateNormal];
        [_centerBTN setImage:ZFPrimaryStage_Image(@"temp_lpa") forState:UIControlStateSelected];
    }
    return _centerBTN;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:ZFPrimaryStage_Image(@"temp_ba") forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (HTAutoScrollLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[HTAutoScrollLabel alloc] init];
    }
    return _titleLabel;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] init];
        UIImage *image = ZFPrimaryStage_Image(@"temp_sh");
        _bottomToolView.layer.contents = (id)image.CGImage;
    }
    return _bottomToolView;
}

- (UIButton *)playFullBack{
    if (!_playFullBack) {
        _playFullBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playFullBack setImage:ZFPrimaryStage_Image(@"temp_lpy") forState:UIControlStateNormal];
    }
    return _playFullBack;
}

- (UIButton *)pointPleaseBtn {
    if (!_pointPleaseBtn) {
        _pointPleaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pointPleaseBtn setImage:ZFPrimaryStage_Image(@"temp_pp") forState:UIControlStateNormal];
        [_pointPleaseBtn setImage:ZFPrimaryStage_Image(@"temp_ppa") forState:UIControlStateSelected];
    }
    return _pointPleaseBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (ZFSliderView *)slider {
    if (!_slider) {
        _slider = [[ZFSliderView alloc] init];
        _slider.delegate = self;
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        _slider.boardTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _slider.minimumTrackTintColor = UIColorFromHex(0x3CDEF4);
        [_slider setThumbImage:ZFPrimaryStage_Image(@"temp_sr") forState:UIControlStateNormal];
        _slider.sliderHeight = 2;
    }
    return _slider;
}

- (UILabel *)tableTimeLabel {
    if (!_tableTimeLabel) {
        _tableTimeLabel = [[UILabel alloc] init];
        _tableTimeLabel.textColor = [UIColor whiteColor];
        _tableTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _tableTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tableTimeLabel;
}

- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:ZFPrimaryStage_Image(@"temp_o") forState:UIControlStateNormal];
        [_lockBtn setImage:ZFPrimaryStage_Image(@"temp_oo") forState:UIControlStateSelected];
    }
    return _lockBtn;
}

- (UIButton *)nextSkip{
    if (!_nextSkip) {
        _nextSkip = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextSkip setImage:ZFPrimaryStage_Image(@"temp_fd") forState:UIControlStateNormal];
        _nextSkip.hidden = YES;
        [_nextSkip setImage:ZFPrimaryStage_Image(@"temp_fd") forState:UIControlStateSelected];
        [_nextSkip addTarget:self action:@selector(nextSkipAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextSkip;
}

- (void)nextSkipAction{
    if (ZFAdManager.shared.ad.next) {
        ZFAdManager.shared.ad.next();
    }
}

@end