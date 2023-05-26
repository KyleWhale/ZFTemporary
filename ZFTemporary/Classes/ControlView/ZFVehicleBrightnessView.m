

#import "ZFVehicleBrightnessView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZFUtilities.h"

@interface ZFVehicleBrightnessView ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) ZFVehicleBrightnessType vehicleType;
@property (nonatomic, strong) MPVolumeView *vehicleView;

@end

@implementation ZFVehicleBrightnessView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconImageView];
        [self addSubview:self.progressView];
        [self hideTipView];
    }
    return self;
}

- (void)dealloc {
    [self addShortVehicleView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.frame.size.width;
    CGFloat min_view_h = self.frame.size.height;
    CGFloat margin = 10;
    
    min_x = margin;
    min_w = 20;
    min_h = min_w;
    min_y = (min_view_h-min_h)/2;
    self.iconImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = CGRectGetMaxX(self.iconImageView.frame) + margin;
    min_h = 2;
    min_y = (min_view_h-min_h)/2;
    min_w = min_view_w - min_x - margin;
    self.progressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    self.layer.cornerRadius = min_view_h/2;
    self.layer.masksToBounds = YES;
}

- (void)hideTipView {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)addShortVehicleView {
    [self.vehicleView removeFromSuperview];
}

- (void)removeShortVehicleView {
    [[UIApplication sharedApplication].keyWindow addSubview:self.vehicleView];
}

- (void)updatePercent:(CGFloat)percent withVehicleType:(ZFVehicleBrightnessType)vehicleType {
    if (percent >= 1) {
        percent = 1;
    } else if (percent <= 0) {
        percent = 0;
    }
    self.progressView.progress = percent;
    self.vehicleType = vehicleType;
    UIImage *image = nil;
    if (vehicleType == ZFVehicleTypeVehicle) {
        if (percent == 0) {
            image = ZFPrimaryStage_Image(@"temp_mu");
        } else if (percent > 0 && percent < 0.5) {
            image = ZFPrimaryStage_Image(@"temp_vl");
        } else {
            image = ZFPrimaryStage_Image(@"temp_vh");
        }
    } else if (vehicleType == ZFVehicleTypeumeBrightness) {
        if (percent >= 0 && percent < 0.5) {
            image = ZFPrimaryStage_Image(@"temp_lo");
        } else {
            image = ZFPrimaryStage_Image(@"temp_hi");
        }
    }
    self.iconImageView.image = image;
    self.hidden = NO;
    self.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTipView) object:nil];
    [self performSelector:@selector(hideTipView) withObject:nil afterDelay:1.5];
}

- (void)setVehicleType:(ZFVehicleBrightnessType)vehicleType {
    _vehicleType = vehicleType;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor whiteColor];
        _progressView.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];;
    }
    return _progressView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}

- (MPVolumeView *)vehicleView {
    if (!_vehicleView) {
        _vehicleView = [[MPVolumeView alloc] init];
        _vehicleView.frame = CGRectMake(-1000, -1000, 100, 100);
    }
    return _vehicleView;
}

@end
