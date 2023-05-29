

#import <UIKit/UIKit.h>

@protocol ZFSliderViewDelegate <NSObject>

@optional
- (void)sliderTouchBegan:(float)value;
- (void)sliderValueChanged:(float)value;
- (void)sliderTouchEnded:(float)value;
- (void)sliderTapped:(float)value;

@end

@interface ZFSliderButton : UIButton

@end

@interface ZFSliderView : UIView

@property (nonatomic, weak) id<ZFSliderViewDelegate> delegate;

@property (nonatomic, strong, readonly) ZFSliderButton *sliderBtn;

@property (nonatomic, strong) UIColor *maximumTrackTintColor;

@property (nonatomic, strong) UIColor *minimumTrackTintColor;

@property (nonatomic, strong) UIColor *boardTintColor;

@property (nonatomic, strong) UIColor *loadingTintColor;

@property (nonatomic, strong) UIImage *maximumTrackImage;

@property (nonatomic, strong) UIImage *minimumTrackImage;

@property (nonatomic, strong) UIImage *bufferTrackImage;

@property (nonatomic, assign) float value;

@property (nonatomic, assign) float basketValue;

@property (nonatomic, assign) BOOL allowTapped;

@property (nonatomic, assign) BOOL animate;

@property (nonatomic, assign) CGFloat sliderHeight;

@property (nonatomic, assign) CGFloat sliderRadius;

@property (nonatomic, assign) BOOL hideSliderBlock;

@property (nonatomic, assign) BOOL itemDragging;

@property (nonatomic, assign) BOOL isForward;

@property (nonatomic, assign) CGSize thumbSize;

- (void)startAnimating;

- (void)stopAnimating;

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;

@end
