

#import <UIKit/UIKit.h>
#import "ZFSliderView.h"
#import "ZFAutoScrollLabel.h"
#if __has_include(<ZFPrimaryStage/ZFPresentController.h>)
#import <ZFPrimaryStage/ZFPresentController.h>
#else
#import "ZFPresentController.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ZFPortraitControlView : UIView

@property (nonatomic, strong, readonly) UIButton *practiceButton;

@property (nonatomic, strong, readonly) UIView *bottomToolView;

@property (nonatomic, strong, readonly) UIView *topToolView;

@property (nonatomic, strong, readonly) ZFAutoScrollLabel *titleLabel;

@property (nonatomic, strong) UIButton *bottomPracticeButton;

@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;

@property (nonatomic, strong, readonly) ZFSliderView *slider;

@property (nonatomic, strong, readonly) UILabel *tableTimeLabel;

@property (nonatomic, strong, readonly) UIButton *fullScreenBtn;

@property (nonatomic, weak) ZFPresentController *player;

@property (nonatomic, copy, nullable) void(^sliderValueChanging)(CGFloat value,BOOL forward);

@property (nonatomic, copy, nullable) void(^sliderValueChanged)(CGFloat value);

@property (nonatomic, copy, nullable) void(^presentPoliteStateChanged)(BOOL play);

@property (nonatomic, assign) BOOL tempTp;

@property (nonatomic, assign) ZFFineScheduleMode fulfilledMode;

@property (nonatomic, strong) UIButton *adButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *ccButton;

- (void)resetControlledView;

- (void)showControlView;

- (void)hideControlView;

- (void)veryPractice:(ZFPresentController *)practiceScreen currentTime:(NSTimeInterval)currentTime tableTime:(NSTimeInterval)tableTime;

- (void)veryPractice:(ZFPresentController *)practiceScreen presentTime:(NSTimeInterval)presentTime;

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPrimaryStageGestureType)type touch:(nonnull UITouch *)touch;

- (void)showTitle:(NSString *_Nullable)title fulfilledMode:(ZFFineScheduleMode)fulfilledMode;

- (void)practiceButtonClick;

- (void)practiceSelected:(BOOL)selected;

- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString;

- (void)sliderChangeEnded;

@end

NS_ASSUME_NONNULL_END
