

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFPresentStatusBar : UIView

@property (nonatomic, assign) NSTimeInterval refreshTime;

- (void)startTimer;

- (void)destoryTimer;

@end



NS_ASSUME_NONNULL_END
