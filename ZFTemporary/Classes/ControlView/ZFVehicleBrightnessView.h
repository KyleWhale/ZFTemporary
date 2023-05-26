

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFVehicleBrightnessType) {
    ZFVehicleTypeVehicle,
    ZFVehicleTypeumeBrightness
};

@interface ZFVehicleBrightnessView : UIView

@property (nonatomic, assign, readonly) ZFVehicleBrightnessType vehicleType;
@property (nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UIImageView *iconImageView;

- (void)updatePercent:(CGFloat)percent withVehicleType:(ZFVehicleBrightnessType)vehicleType;

- (void)addShortVehicleView;

- (void)removeShortVehicleView;

@end
