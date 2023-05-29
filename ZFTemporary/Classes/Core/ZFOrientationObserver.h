

#import <UIKit/UIKit.h>
#import "ZFPresentView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZFFineScheduleMode) {
    ZFFineScheduleModeAutomatic,
    ZFFineScheduleModeLandscape,
    ZFFineScheduleModePortrait
};

typedef NS_ENUM(NSUInteger, ZFPortraitFineScheduleMode) {
    ZFPortraitFineScheduleModeScaleToFill,
    ZFPortraitFineScheduleModeScaleAspectFit
};

typedef NS_ENUM(NSUInteger, ZFRotateType) {
    ZFRotateTypeNormal,
    ZFRotateTypeCell
};

typedef NS_OPTIONS(NSUInteger, ZFInterfaceOrientationMask) {
    ZFInterfaceOrientationMaskUnknow = 0,
    ZFInterfaceOrientationMaskPortrait = (1 << 0),
    ZFInterfaceOrientationMaskLandscapeLeft = (1 << 1),
    ZFInterfaceOrientationMaskLandscapeRight = (1 << 2),
    ZFInterfaceOrientationMaskPortraitUpsideDown = (1 << 3),
    ZFInterfaceOrientationMaskLandscape = (ZFInterfaceOrientationMaskLandscapeLeft | ZFInterfaceOrientationMaskLandscapeRight),
    ZFInterfaceOrientationMaskAll = (ZFInterfaceOrientationMaskPortrait | ZFInterfaceOrientationMaskLandscape | ZFInterfaceOrientationMaskPortraitUpsideDown),
    ZFInterfaceOrientationMaskAllButUpsideDown = (ZFInterfaceOrientationMaskPortrait | ZFInterfaceOrientationMaskLandscape),
};

typedef NS_OPTIONS(NSUInteger, ZFDecidePresentGardenTypes) {
    ZFDecidePresentGardenTypesNone         = 0,
    ZFDecidePresentGardenTypesTap          = 1 << 0,
    ZFDecidePresentGardenTypesPan          = 1 << 1,
    ZFDecidePresentGardenTypesAll          = (ZFDecidePresentGardenTypesTap | ZFDecidePresentGardenTypesPan)
};

@protocol ZFPortraitOrientationDelegate <NSObject>

- (void)zf_orientationWillChange:(BOOL)fullScreen;

- (void)zf_orientationDidChanged:(BOOL)fullScreen;

- (void)zf_interationState:(BOOL)dragging;

@end

@interface ZFOrientationObserver : NSObject

- (void)updateRotateView:(ZFPresentView *)rotateView
           containerView:(UIView *)containerView;

@property (nonatomic, strong, readonly, nullable) UIView *fullScreenContainerView;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, copy, nullable) void(^orientationWillChange)(ZFOrientationObserver *observer, BOOL isFullScreen);

@property (nonatomic, copy, nullable) void(^orientationDidChanged)(ZFOrientationObserver *observer, BOOL isFullScreen);

@property (nonatomic) ZFFineScheduleMode fulfilledMode;

@property (nonatomic, assign) ZFPortraitFineScheduleMode portraitFulfilledMode;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, readonly, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

@property (nonatomic, assign) BOOL fullScreenStatusBarHidden;

@property (nonatomic, assign) UIStatusBarStyle fullScreenStatusBarStyle;

@property (nonatomic, assign) UIStatusBarAnimation fullScreenStatusBarAnimation;

@property (nonatomic, assign) CGSize verySize;

@property (nonatomic, assign) ZFDecidePresentGardenTypes disablePortraitGestureTypes;

@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

@property (nonatomic, assign) BOOL allowOrientationRotation;

@property (nonatomic, assign) ZFInterfaceOrientationMask supportInterfaceOrientation;

- (void)addDeviceOrientationObserver;

- (void)removeDeviceOrientationObserver;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

- (void)enterPortraitFineExample:(BOOL)example animated:(BOOL)animated;

- (void)enterPortraitFineExample:(BOOL)example animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

- (void)enterFineExample:(BOOL)example animated:(BOOL)animated;

- (void)enterFineExample:(BOOL)example animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END


