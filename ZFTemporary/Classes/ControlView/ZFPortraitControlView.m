

#import "ZFPortraitControlView.h"
#import "UIView+ZFFrame.h"
#import "ZFUtilities.h"
#import "ZFAdManager.h"
#import "Masonry.h"
#import "ZFPrimaryConst.h"

@interface ZFPortraitControlView () <ZFSliderViewDelegate>
@property (nonatomic, strong) UIView *bottomToolView;
@property (nonatomic, strong) UIView *topToolView;
@property (nonatomic, strong) ZFAutoScrollLabel *titleLabel;
@property (nonatomic, strong) UIButton *practiceButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) ZFSliderView *slider;
@property (nonatomic, strong) UILabel *tableTimeLabel;
@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation ZFPortraitControlView

- (UIStackView *)stackView{
    if(!_stackView){
        _stackView = UIStackView.new;
        _stackView.spacing = 10;
    }
    return _stackView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topToolView];
        [self addSubview:self.bottomToolView];
        [self.topToolView addSubview:self.titleLabel];
        [self.topToolView addSubview:self.stackView];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.tableTimeLabel];
        [self.bottomToolView addSubview:self.fullScreenBtn];
        [self.bottomToolView addSubview:self.bottomPracticeButton];
        [self.stackView addArrangedSubview:self.adBTN];
        [self.stackView addArrangedSubview:self.ccBTN];
        [self.stackView addArrangedSubview:self.shareBTN];
        [self makeSubViewsAction];
        
        [self resetControlledView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    CGFloat min_margin = 9;
    
    min_x = 0;
    min_y = ZFIPhoneX?0:ZFNavigationStatusBar;
    min_w = min_view_w;
    min_h = 40;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    self.adBTN.hidden = [ZFAdManager.shared.ad sub];
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(0);
    }];
    [self.stackView layoutIfNeeded];
    self.adBTN.layer.cornerRadius = self.adBTN.frame.size.height / 2.0;
    self.adBTN.layer.masksToBounds = YES;
    self.adBTN.backgroundColor = UIColorFromHex(0xECCD6E);
    
    min_x = 45;
    min_y = 0;
    min_w = min_view_w - min_x - 20- self.stackView.frame.size.width;
    min_h = 40;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    [self.titleLabel animationScroll];
    
    min_h = 40;
    min_x = 0;
    min_y = min_view_h - min_h;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = 44;
    min_h = min_w;
    self.practiceButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.practiceButton.center = self.center;
    
    
    min_x = min_margin;
    min_w = 25;
    min_h = 25;
    min_y = (self.bottomToolView.zf_height - min_h)/2;
    self.bottomPracticeButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = self.bottomPracticeButton.zf_right  ;
    min_w = 62;
    min_h = 28;
    min_y = (self.bottomToolView.zf_height - min_h)/2;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 28;
    min_h = min_w;
    min_x = self.bottomToolView.zf_width - min_w - min_margin;
    min_y = 0;
    self.fullScreenBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.fullScreenBtn.zf_centerY = self.currentTimeLabel.zf_centerY;
    
    min_w = 62;
    min_h = 28;
    min_x = self.fullScreenBtn.zf_left - min_w - 4;
    min_y = 0;
    self.tableTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.tableTimeLabel.zf_centerY = self.currentTimeLabel.zf_centerY;
    
    min_x = self.currentTimeLabel.zf_right + 4;
    min_y = 0;
    min_w = self.tableTimeLabel.zf_left - min_x - 4;
    min_h = 30;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.slider.zf_centerY = self.currentTimeLabel.zf_centerY;
    if (!self.isShow) {
        self.topToolView.zf_y = -self.topToolView.zf_height;
        self.bottomToolView.zf_y = self.zf_height;
        self.practiceButton.alpha = 0;
    } else {
        self.topToolView.zf_y = ZFIPhoneX?0:ZFNavigationStatusBar;
        self.bottomToolView.zf_y = self.zf_height - self.bottomToolView.zf_height;
        self.practiceButton.alpha = 1;
    }
}

- (void)adAction{
    
    if (ZFAdManager.shared.ad.remove) {
        ZFAdManager.shared.ad.remove();
    }
}

- (void)ccAction{
    if (ZFAdManager.shared.ad.first) {
        ZFAdManager.shared.ad.first();
    }
}

- (void)shareAction{
    if (ZFAdManager.shared.ad.second) {
        ZFAdManager.shared.ad.second();
    }
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
        [_shareBTN setImage:ZFPrimaryStage_Image(@"temp_tpg") forState:UIControlStateNormal];
        _shareBTN.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [_shareBTN addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBTN;
}

- (void)makeSubViewsAction {
    [self.bottomPracticeButton addTarget:self action:@selector(makeButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.practiceButton addTarget:self action:@selector(makeButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - action

- (void)makeButtonClickAction:(UIButton *)sender {
    [self practiceButtonClick];
}

- (void)fullScreenButtonClickAction:(UIButton *)sender {
    [self.player enterFineExample:YES animated:YES];
}

- (void)practiceButtonClick {
    self.practiceButton.selected = !self.practiceButton.isSelected;
    self.bottomPracticeButton.selected = !self.bottomPracticeButton.isSelected;
    self.practiceButton.isSelected? [self.player.periodManager play]: [self.player.periodManager pause];
    if(self.presentPoliteStateChanged) self.presentPoliteStateChanged(self.player.periodManager.state == ZFPrimaryStagePresentStatePolite);
}

- (void)practiceSelected:(BOOL)selected {
    self.practiceButton.selected = selected;
    self.bottomPracticeButton.selected = selected;
}

- (void)sliderTouchBegan:(float)value {
    self.slider.isdragging = YES;
}

- (void)sliderTouchEnded:(float)value {
    if (self.player.tableTime > 0) {
        self.slider.isdragging = YES;
        if (self.sliderValueChanging) self.sliderValueChanging(value, self.slider.isForward);
        @zf_weakify(self)
        [self.player seekToTime:self.player.tableTime*value completionHandler:^(BOOL finished) {
            @zf_strongify(self)
            self.slider.isdragging = NO;
            if (self.sliderValueChanged) self.sliderValueChanged(value);
            if (self.tempTp) {
                [self.player.periodManager play];
            }
        }];
        if (self.tempTp) {
            [self.player.periodManager play];
        }
    } else {
        self.slider.isdragging = NO;
        self.slider.value = 0;
    }
}

- (void)sliderValueChanged:(float)value {
    if (self.player.tableTime == 0) {
        self.slider.value = 0;
        return;
    }
    self.slider.isdragging = YES;
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.player.tableTime*value];
    self.currentTimeLabel.text = currentTimeString;
    if (self.sliderValueChanging) self.sliderValueChanging(value,self.slider.isForward);
}

- (void)sliderTapped:(float)value {
    [self sliderTouchEnded:value];
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.player.tableTime*value];
    self.currentTimeLabel.text = currentTimeString;
}

#pragma mark - public method

- (void)resetControlledView {
    self.bottomToolView.alpha        = 1;
    self.slider.value                = 0;
    self.slider.basketValue          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.tableTimeLabel.text         = @"00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.practiceButton.selected     = YES;
    self.titleLabel.textLabel.text             = @"";
}

- (void)showControlView {
    self.topToolView.alpha           = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = YES;
    self.topToolView.zf_y            = ZFIPhoneX?0:ZFNavigationStatusBar;;
    self.bottomToolView.zf_y         = self.zf_height - self.bottomToolView.zf_height;
    self.practiceButton.alpha        = 1;
    self.player.statusBarHidden      = NO;
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.topToolView.zf_y            = -self.topToolView.zf_height;
    self.bottomToolView.zf_y         = self.zf_height;
    self.player.statusBarHidden      = NO;
    self.practiceButton.alpha        = 0;
    self.topToolView.alpha           = 0;
    self.bottomToolView.alpha        = 0;
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPrimaryStageGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    return YES;
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
    self.player.orientationObserver.fulfilledMode = fulfilledMode;
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
    self.player.orientationObserver.fulfilledMode = fulfilledMode;
}

#pragma mark - getter

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
    }
    return _topToolView;
}

- (ZFAutoScrollLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[ZFAutoScrollLabel alloc] init];
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

- (UIButton *)practiceButton {
    if (!_practiceButton) {
        _practiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_practiceButton setImage:ZFPrimaryStage_Image(@"temp_pl") forState:UIControlStateNormal];
        [_practiceButton setImage:ZFPrimaryStage_Image(@"temp_pa") forState:UIControlStateSelected];
    }
    return _practiceButton;
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

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:ZFPrimaryStage_Image(@"temp_fe") forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
}

- (UIButton *)bottomPracticeButton {
    if (!_bottomPracticeButton) {
        _bottomPracticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomPracticeButton setImage:ZFPrimaryStage_Image(@"temp_pp") forState:UIControlStateNormal];
        [_bottomPracticeButton setImage:ZFPrimaryStage_Image(@"temp_ppa") forState:UIControlStateSelected];
    }
    return _bottomPracticeButton;
}

@end
