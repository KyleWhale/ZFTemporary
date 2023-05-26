

#import "ZFPresentView.h"
#import "ZFPrimaryConst.h"

@implementation ZFPresentView
@synthesize verySize = _verySize;
@synthesize coverImageView = _coverImageView;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.coverImageView];
    }
    return self;
}

- (void)setPlayerView:(UIView *)playerView {
    if (_playerView) {
        [_playerView removeFromSuperview];
        self.verySize = CGSizeZero;
    }
    _playerView = playerView;
    if (playerView != nil) {
        [self addSubview:playerView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    CGSize viewSize = CGSizeZero;
    CGFloat verticalWidth = self.verySize.width;
    CGFloat verticalHeight = self.verySize.height;
    if (verticalHeight == 0) return;
    CGFloat screenScale = min_view_w/min_view_h;
    CGFloat verticalScale = verticalWidth/verticalHeight;
    if (screenScale > verticalScale) {
        CGFloat height = min_view_h;
        CGFloat width = height * verticalScale;
        viewSize = CGSizeMake(width, height);
    } else {
        CGFloat width = min_view_w;
        CGFloat height = width / verticalScale;
        viewSize = CGSizeMake(width, height);
    }
    
    if (self.scalingMode == ZFPrimaryStageScalingModeNone || self.scalingMode == ZFPrimaryStageScalingModeAspectFit) {
        min_w = viewSize.width;
        min_h = viewSize.height;
        min_x = (min_view_w - min_w) / 2.0;
        min_y = (min_view_h - min_h) / 2.0;
        self.playerView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    } else if (self.scalingMode == ZFPrimaryStageScalingModeAspectFill || self.scalingMode == ZFPrimaryStageScalingModeFill) {
        self.playerView.frame = self.bounds;
    }
    self.coverImageView.frame = self.playerView.frame;
}

- (CGSize)verySize {
    if (CGSizeEqualToSize(_verySize, CGSizeZero)) {
        _verySize = self.frame.size;
    }
    return _verySize;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (void)setScalingMode:(ZFPrimaryStageScalingMode)scalingMode {
    _scalingMode = scalingMode;
     if (scalingMode == ZFPrimaryStageScalingModeNone || scalingMode == ZFPrimaryStageScalingModeAspectFit) {
         self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else if (scalingMode == ZFPrimaryStageScalingModeAspectFill) {
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (scalingMode == ZFPrimaryStageScalingModeFill) {
        self.coverImageView.contentMode = UIViewContentModeScaleToFill;
    }
    [self layoutIfNeeded];
}

- (void)setVerySize:(CGSize)verySize {
    _verySize = verySize;
    if (CGSizeEqualToSize(CGSizeZero, verySize)) return;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
