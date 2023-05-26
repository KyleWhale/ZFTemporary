

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZFPrimaryStageGestureType) {
    ZFPrimaryStageGestureTypeUnknown,
    ZFPrimaryStageGestureTypeSingleTap,
    ZFPrimaryStageGestureTypeDoubleTap,
    ZFPrimaryStageGestureTypePan,
    ZFPrimaryStageGestureTypePinch
};

typedef NS_ENUM(NSUInteger, ZFPanDirection) {
    ZFPanDirectionUnknown,
    ZFPanDirectionVertical,
    ZFPanDirectionHorizontal,
};

typedef NS_ENUM(NSUInteger, ZFPanLocation) {
    ZFPanLocationUnknown,
    ZFPanLocationLeft,
    ZFPanLocationRight,
};

typedef NS_ENUM(NSUInteger, ZFPanMovingDirection) {
    ZFPanMovingDirectionUnkown,
    ZFPanMovingDirectionTop,
    ZFPanMovingDirectionLeft,
    ZFPanMovingDirectionBottom,
    ZFPanMovingDirectionRight,
};

typedef NS_OPTIONS(NSUInteger, ZFPrimaryStageDisableGestureTypes) {
    ZFPrimaryStageDisableGestureTypesNone         = 0,
    ZFPrimaryStageDisableGestureTypesSingleTap    = 1 << 0,
    ZFPrimaryStageDisableGestureTypesDoubleTap    = 1 << 1,
    ZFPrimaryStageDisableGestureTypesPan          = 1 << 2,
    ZFPrimaryStageDisableGestureTypesPinch        = 1 << 3,
    ZFPrimaryStageDisableGestureTypesLongPress    = 1 << 4,
    ZFPrimaryStageDisableGestureTypesAll          = (ZFPrimaryStageDisableGestureTypesSingleTap | ZFPrimaryStageDisableGestureTypesDoubleTap | ZFPrimaryStageDisableGestureTypesPan | ZFPrimaryStageDisableGestureTypesPinch | ZFPrimaryStageDisableGestureTypesLongPress)
};

typedef NS_OPTIONS(NSUInteger, ZFPrimaryStageDisablePanMovingDirection) {
    ZFPrimaryStageDisablePanMovingDirectionNone         = 0,
    ZFPrimaryStageDisablePanMovingDirectionVertical     = 1 << 0,
    ZFPrimaryStageDisablePanMovingDirectionHorizontal   = 1 << 1,
    ZFPrimaryStageDisablePanMovingDirectionAll          = (ZFPrimaryStageDisablePanMovingDirectionVertical | ZFPrimaryStageDisablePanMovingDirectionHorizontal)
};

typedef NS_ENUM(NSUInteger, ZFLongPressGestureRecognizerState) {
    ZFLongPressGestureRecognizerStateBegan,
    ZFLongPressGestureRecognizerStateChanged,
    ZFLongPressGestureRecognizerStateEnded
};

@interface ZFPresentGestureControl : NSObject

@property (nonatomic, copy, nullable) BOOL(^triggerCondition)(ZFPresentGestureControl *control, ZFPrimaryStageGestureType type, UIGestureRecognizer *gesture, UITouch *touch);

@property (nonatomic, copy, nullable) void(^singleTapped)(ZFPresentGestureControl *control);

@property (nonatomic, copy, nullable) void(^doubleTapped)(ZFPresentGestureControl *control);

@property (nonatomic, copy, nullable) void(^beganPan)(ZFPresentGestureControl *control, ZFPanDirection direction, ZFPanLocation location);

@property (nonatomic, copy, nullable) void(^changedPan)(ZFPresentGestureControl *control, ZFPanDirection direction, ZFPanLocation location, CGPoint velocity);

@property (nonatomic, copy, nullable) void(^endedPan)(ZFPresentGestureControl *control, ZFPanDirection direction, ZFPanLocation location);

@property (nonatomic, copy, nullable) void(^pinched)(ZFPresentGestureControl *control, float scale);

@property (nonatomic, copy, nullable) void(^longPressed)(ZFPresentGestureControl *control, ZFLongPressGestureRecognizerState state);

@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;

@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinchGR;

@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGR;

@property (nonatomic, readonly) ZFPanDirection panDirection;

@property (nonatomic, readonly) ZFPanLocation panLocation;

@property (nonatomic, readonly) ZFPanMovingDirection panMovingDirection;

@property (nonatomic) ZFPrimaryStageDisableGestureTypes disableTypes;

@property (nonatomic) ZFPrimaryStageDisablePanMovingDirection disablePanMovingDirection;

- (void)addGestureToView:(UIView *)view;

- (void)removeGestureToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
