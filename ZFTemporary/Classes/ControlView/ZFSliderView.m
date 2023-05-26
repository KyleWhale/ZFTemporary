

#import "ZFSliderView.h"
#import "UIView+ZFFrame.h"

static const CGFloat kSliderBtnWH = 19.0;
static const CGFloat kProgressH = 1.0;
static const CGFloat kAnimate = 0.3;

@implementation ZFSliderButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -20, -20);
    return CGRectContainsPoint(bounds, point);
}

@end

@interface ZFSliderView ()

@property (nonatomic, strong) UIImageView *backView;
@property (nonatomic, strong) UIImageView *brownView;
@property (nonatomic, strong) UIImageView *stateView;
@property (nonatomic, strong) ZFSliderButton *sliderBtn;

@property (nonatomic, strong) UIView *loadingBarView;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation ZFSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.allowTapped = YES;
        self.animate = YES;
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.allowTapped = YES;
    self.animate = YES;
    [self addSubViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (isnan(self.value) || isnan(self.basketValue)) return;

    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    min_x = 0;
    min_w = min_view_w;
    min_y = 0;
    min_h = self.sliderHeight;
    self.backView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = self.thumbSize.width;
    min_h = self.thumbSize.height;
    self.sliderBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.sliderBtn.zf_centerX = self.backView.zf_width * self.value;
    
    min_x = 0;
    min_y = 0;
    if (self.sliderBtn.hidden) {
        min_w = self.backView.zf_width * self.value;
    } else {
        min_w = self.sliderBtn.zf_centerX;
    }
    min_h = self.sliderHeight;
    self.stateView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = self.backView.zf_width * self.basketValue;
    min_h = self.sliderHeight;
    self.brownView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 0.1;
    min_h = self.sliderHeight;
    min_x = (min_view_w - min_w)/2;
    min_y = (min_view_h - min_h)/2;
    self.loadingBarView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    self.backView.zf_centerY     = min_view_h * 0.5;
    self.brownView.zf_centerY = min_view_h * 0.5;
    self.stateView.zf_centerY = min_view_h * 0.5;
    self.sliderBtn.zf_centerY          = min_view_h * 0.5;
}

- (void)addSubViews {
    self.thumbSize = CGSizeMake(kSliderBtnWH, kSliderBtnWH);
    self.sliderHeight = kProgressH;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    [self addSubview:self.brownView];
    [self addSubview:self.stateView];
    [self addSubview:self.sliderBtn];
    [self addSubview:self.loadingBarView];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapGesture];
    
    UIPanGestureRecognizer *sliderGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderGesture:)];
    [self addGestureRecognizer:sliderGesture];
}

#pragma mark - Setter

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    self.backView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    self.stateView.backgroundColor = minimumTrackTintColor;
}

- (void)setBoardTintColor:(UIColor *)boardTintColor {
    _boardTintColor = boardTintColor;
    self.brownView.backgroundColor = boardTintColor;
}

- (void)setLoadingTintColor:(UIColor *)loadingTintColor {
    _loadingTintColor = loadingTintColor;
    self.loadingBarView.backgroundColor = loadingTintColor;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    _maximumTrackImage = maximumTrackImage;
    self.backView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    _minimumTrackImage = minimumTrackImage;
    self.stateView.image = minimumTrackImage;
    self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
    _bufferTrackImage = bufferTrackImage;
    self.brownView.image = bufferTrackImage;
    self.boardTintColor = [UIColor clearColor];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setBackgroundImage:image forState:state];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setImage:image forState:state];
}

- (void)setValue:(float)value {
    if (isnan(value)) return;
    value = MIN(1.0, value);
    _value = value;
    if (self.sliderBtn.hidden) {
        self.stateView.zf_width = self.backView.zf_width * value;
    } else {
        self.sliderBtn.zf_centerX = self.backView.zf_width * value;
        self.stateView.zf_width = self.sliderBtn.zf_centerX;
    }
}

- (void)setBasketValue:(float)basketValue {
    if (isnan(basketValue)) return;
    basketValue = MIN(1.0, basketValue);
    _basketValue = basketValue;
    self.brownView.zf_width = self.backView.zf_width * basketValue;
}

- (void)setAllowTapped:(BOOL)allowTapped {
    _allowTapped = allowTapped;
    if (!allowTapped) {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    if (isnan(sliderHeight)) return;
    _sliderHeight = sliderHeight;
    self.backView.zf_height     = sliderHeight;
    self.brownView.zf_height = sliderHeight;
    self.stateView.zf_height = sliderHeight;
}

- (void)setSliderRadius:(CGFloat)sliderRadius {
    if (isnan(sliderRadius)) return;
    _sliderRadius = sliderRadius;
    self.backView.layer.cornerRadius      = sliderRadius;
    self.brownView.layer.cornerRadius  = sliderRadius;
    self.stateView.layer.cornerRadius  = sliderRadius;
    self.backView.layer.masksToBounds     = YES;
    self.brownView.layer.masksToBounds = YES;
    self.stateView.layer.masksToBounds = YES;
}

- (void)setIsHideSliderBlock:(BOOL)isHideSliderBlock {
    _isHideSliderBlock = isHideSliderBlock;
    if (isHideSliderBlock) {
        self.sliderBtn.hidden = YES;
        self.backView.zf_left     = 0;
        self.brownView.zf_left = 0;
        self.stateView.zf_left = 0;
        self.allowTapped = NO;
    }
}

- (void)startAnimating {
    if (self.isLoading) return;
    self.isLoading = YES;
    self.brownView.hidden = YES;
    self.stateView.hidden = YES;
    self.sliderBtn.hidden = YES;
    self.loadingBarView.hidden = NO;
    
    [self.loadingBarView.layer removeAllAnimations];
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.duration = 0.4;
    animationGroup.beginTime = CACurrentMediaTime() + 0.4;
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animation];
    scaleAnimation.keyPath = @"transform.scale.x";
    scaleAnimation.fromValue = @(1000.0f);
    scaleAnimation.toValue = @(self.zf_width * 10);
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animation];
    alphaAnimation.keyPath = @"opacity";
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.0f);
    
    [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
    [self.loadingBarView.layer addAnimation:animationGroup forKey:@"loading"];
}

- (void)stopAnimating {
    self.isLoading = NO;
    self.brownView.hidden = NO;
    self.stateView.hidden = NO;
    self.sliderBtn.hidden = self.isHideSliderBlock;
    self.loadingBarView.hidden = YES;
    [self.loadingBarView.layer removeAllAnimations];
}

#pragma mark - User Action

- (void)sliderGesture:(UIGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self sliderBtnTouchBegin:self.sliderBtn];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            [self sliderBtnDragMoving:self.sliderBtn point:[gesture locationInView:self.backView]];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self sliderBtnTouchEnded:self.sliderBtn];
        }
            break;
        default:
            break;
    }
}

- (void)sliderBtnTouchBegin:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sliderTouchBegan:)]) {
        [self.delegate sliderTouchBegan:self.value];
    }
    if (self.animate) {
        [UIView animateWithDuration:kAnimate animations:^{
            btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
    }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sliderTouchEnded:)]) {
        [self.delegate sliderTouchEnded:self.value];
    }
    if (self.animate) {
        [UIView animateWithDuration:kAnimate animations:^{
            btn.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)sliderBtnDragMoving:(UIButton *)btn point:(CGPoint)touchPoint {
    CGPoint point = touchPoint;
    CGFloat value = (point.x - btn.zf_width * 0.5) / self.backView.zf_width;
    value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value;
    if (self.value == value) return;
    self.isForward = self.value < value;
    self.value = value;
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:value];
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.backView];
    CGFloat value = (point.x - self.sliderBtn.zf_width * 0.5) * 1.0 / self.backView.zf_width;
    value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
    self.value = value;
    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
        [self.delegate sliderTapped:value];
    }
}

#pragma mark - getter

- (UIView *)backView {
    if (!_backView) {
        _backView = [UIImageView new];
        _backView.backgroundColor = [UIColor grayColor];
        _backView.contentMode = UIViewContentModeScaleAspectFill;
        _backView.clipsToBounds = YES;
    }
    return _backView;
}

- (UIView *)brownView {
    if (!_brownView) {
        _brownView = [UIImageView new];
        _brownView.backgroundColor = [UIColor whiteColor];
        _brownView.contentMode = UIViewContentModeScaleAspectFill;
        _brownView.clipsToBounds = YES;
    }
    return _brownView;
}

- (UIView *)stateView {
    if (!_stateView) {
        _stateView = [UIImageView new];
        _stateView.backgroundColor = [UIColor redColor];
        _stateView.contentMode = UIViewContentModeScaleAspectFill;
        _stateView.clipsToBounds = YES;
    }
    return _stateView;
}

- (ZFSliderButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [ZFSliderButton buttonWithType:UIButtonTypeCustom];
        [_sliderBtn setAdjustsImageWhenHighlighted:NO];
    }
    return _sliderBtn;
}

- (UIView *)loadingBarView {
    if (!_loadingBarView) {
        _loadingBarView = [[UIView alloc] init];
        _loadingBarView.backgroundColor = [UIColor whiteColor];
        _loadingBarView.hidden = YES;
    }
    return _loadingBarView;
}

@end
