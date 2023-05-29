

#import <UIKit/UIKit.h>
#import "ZFPortraitControlView.h"
#import "ZFLightControlView.h"
#import "ZFSpeedLaughView.h"
#import "ZFSmallFloatControlView.h"
#import "ZFPrimaryViewControl.h"

@interface ZFPresentControlView : UIView <ZFPrimaryViewControl>

@property (nonatomic, strong, readonly) ZFPortraitControlView *portraitControlView;

@property (nonatomic, strong, readonly) ZFLightControlView *lightControlView;

@property (nonatomic, strong, readonly) ZFSpeedLaughView *laughView;

@property (nonatomic, strong, readonly) UIView *fastView;

@property (nonatomic, strong, readonly) ZFSliderView *fastProperView;

@property (nonatomic, strong, readonly) UILabel *firstLabel;

@property (nonatomic, strong, readonly) UIImageView *firstImageView;

@property (nonatomic, strong, readonly) UIButton *errorButton;

@property (nonatomic, strong, readonly) ZFSliderView *bottomPresentView;

@property (nonatomic, strong, readonly) UIImageView *coverImageView;

@property (nonatomic, strong, readonly) UIImageView *bgImgView;

@property (nonatomic, strong, readonly) UIView *emptyView;

@property (nonatomic, strong, readonly) ZFSmallFloatControlView *floatControlView;

@property (nonatomic, assign) BOOL firstViewAnimated;

@property (nonatomic, assign) BOOL primaryViewShow;

@property (nonatomic, assign) BOOL tempTp;

@property (nonatomic, copy) void(^backBtnClickCallback)(void);

@property (nonatomic, readonly) BOOL controlViewAppeared;

@property (nonatomic, copy) void(^controlViewAppearedCallback)(BOOL appeared);

@property (nonatomic, assign) NSTimeInterval hiddenTime;

@property (nonatomic, assign) NSTimeInterval fadeTime;

@property (nonatomic, assign) BOOL horizontalPanShowControlView;

@property (nonatomic, assign) BOOL prepareShowView;

@property (nonatomic, assign) BOOL showLoading;

@property (nonatomic, assign) BOOL customDisablePanMovingDirection;

@property (nonatomic, assign) BOOL showCustomStatusBar;

@property (nonatomic, assign) ZFFineScheduleMode fulfilledMode;

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl fulfilledMode:(ZFFineScheduleMode)fulfilledMode;

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl placeholderImage:(UIImage *)placeholder fulfilledMode:(ZFFineScheduleMode)fulfilledMode;

- (void)showTitle:(NSString *)title coverImage:(UIImage *)image fulfilledMode:(ZFFineScheduleMode)fulfilledMode;

- (void)resetControlledView;

@end
