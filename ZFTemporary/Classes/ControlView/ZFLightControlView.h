
#import "HTAutoScrollLabel.h"
#import <UIKit/UIKit.h>
#import "ZFSliderView.h"
#import "ZFPresentController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFLightControlView : UIView
@property (nonatomic, strong, readonly) UIView *topToolView;

@property (nonatomic, strong, readonly) UIButton *backBtn;

@property (nonatomic, strong) HTAutoScrollLabel *titleLabel;

@property (nonatomic, strong, readonly) UIView *bottomToolView;

@property (nonatomic, strong, readonly) UIButton *pointPleaseBtn;

@property (nonatomic, strong) UIButton *playFullBack;

@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;

@property (nonatomic, strong, readonly) ZFSliderView *slider;

@property (nonatomic, strong, readonly) UILabel *tableTimeLabel;

@property (nonatomic, strong, readonly) UIButton *lockBtn;

@property (nonatomic, assign) BOOL showCustomStatusBar;

@property (nonatomic, weak) ZFPresentController *primaryStage;

@property (nonatomic, assign) BOOL centerAd;

@property (nonatomic, copy, nullable) void(^sliderValueChanging)(CGFloat value,BOOL forward);

@property (nonatomic, copy, nullable) void(^sliderValueChanged)(CGFloat value);

@property (nonatomic, copy) void(^backBtnClickCallback)(void);
@property (nonatomic, copy) void(^controlBlock)(void);
@property (nonatomic, copy, nullable) void(^presentPoliteStateChanged)(BOOL play);
@property (nonatomic, assign) BOOL tempTp;

@property (nonatomic, assign) ZFFineScheduleMode fulfilledMode;

@property (nonatomic, strong) UIButton *leftBTN;
@property (nonatomic, strong) UIButton *centerBTN;
@property (nonatomic, strong) UIButton *rightBTN;
@property (nonatomic, strong) UIStackView *centerTool;

@property (nonatomic, strong) UIStackView *topStasckView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIStackView *leftStackView;

@property (nonatomic, strong) UIButton *adBTN;
@property (nonatomic, strong) UIButton *shareBTN;
@property (nonatomic, strong) UIButton *ccBTN;
@property (nonatomic, strong) UIButton *episodes;

@property (nonatomic, strong) UIButton *fullBTN;
@property (nonatomic, strong) UIButton *toupingBTN;
@property (nonatomic, strong) UIButton *collectBTN;
@property (nonatomic, strong) UIButton *nextSkip;

- (void)resetControlledView;

- (void)showControlView;

- (void)hideControlView;

- (void)veryPractice:(ZFPresentController *)practiceScreen currentTime:(NSTimeInterval)currentTime tableTime:(NSTimeInterval)tableTime;

- (void)veryPractice:(ZFPresentController *)practiceScreen presentTime:(NSTimeInterval)presentTime;

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPrimaryStageGestureType)type touch:(nonnull UITouch *)touch;

- (void)veryPractice:(ZFPresentController *)practiceScreen presentChangedSize:(CGSize)size;

- (void)veryPractice:(ZFPresentController *)practiceScreen orientationWillChange:(ZFOrientationObserver *)observer;

- (void)showTitle:(NSString *_Nullable)title fulfilledMode:(ZFFineScheduleMode)fulfilledMode;

- (void)pointPleaseClick;

- (void)practiceSelected:(BOOL)selected;

- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString;

- (void)sliderChangeEnded;
- (void)backAction;
@end

NS_ASSUME_NONNULL_END
