

#import "ZFPresentNotification.h"

@interface ZFPresentNotification ()

@property (nonatomic, assign) ZFPrimaryStageBackgroundState backgroundState;

@end

@implementation ZFPresentNotification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionRouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vehicleDidChangeNotification:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterruptionNotification:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)dealloc {
    [self removeNotification];
}

- (void)audioSessionRouteChangeNotification:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *interuptionDict = notification.userInfo;
        NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        switch (routeChangeReason) {
            case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
                if (self.newDeviceAvailable) self.newDeviceAvailable(self);
            }
                break;
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
                if (self.oldDeviceUnavailable) self.oldDeviceUnavailable(self);
            }
                break;
            case AVAudioSessionRouteChangeReasonCategoryChange: {
                if (self.categoryChange) self.categoryChange(self);
            }
                break;
        }
    });
}

- (void)vehicleDidChangeNotification:(NSNotification *)notification {
    float vehicle = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (self.vehicleChanged) self.vehicleChanged(vehicle);
}

- (void)applicationWillResignActiveNotification {
    self.backgroundState = ZFPrimaryStageBackgroundStateBackground;
    if (_willResignActive) _willResignActive(self);
}

- (void)applicationDidBecomeActiveNotification {
    self.backgroundState = ZFPrimaryStageBackgroundStateForeground;
    if (_didBecomeActive) _didBecomeActive(self);
}

- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    AVAudioSessionInterruptionType interruptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (self.audioInterruptionCallback) self.audioInterruptionCallback(interruptionType);
}

@end
