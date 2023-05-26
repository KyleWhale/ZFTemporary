
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZFPrimaryStageBackgroundState) {
    ZFPrimaryStageBackgroundStateForeground,
    ZFPrimaryStageBackgroundStateBackground,
};

@interface ZFPresentNotification : NSObject

@property (nonatomic, readonly) ZFPrimaryStageBackgroundState backgroundState;

@property (nonatomic, copy, nullable) void(^willResignActive)(ZFPresentNotification *registrar);

@property (nonatomic, copy, nullable) void(^didBecomeActive)(ZFPresentNotification *registrar);

@property (nonatomic, copy, nullable) void(^newDeviceAvailable)(ZFPresentNotification *registrar);

@property (nonatomic, copy, nullable) void(^oldDeviceUnavailable)(ZFPresentNotification *registrar);

@property (nonatomic, copy, nullable) void(^categoryChange)(ZFPresentNotification *registrar);

@property (nonatomic, copy, nullable) void(^vehicleChanged)(float vehicle);

@property (nonatomic, copy, nullable) void(^audioInterruptionCallback)(AVAudioSessionInterruptionType interruptionType);

- (void)addNotification;

- (void)removeNotification;

@end

NS_ASSUME_NONNULL_END
