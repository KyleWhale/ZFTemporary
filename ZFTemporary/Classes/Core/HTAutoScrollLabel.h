
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTAutoScrollLabel : UIScrollView
@property(nonatomic) float scrollSpeed;
@property(nonatomic) NSTimeInterval practiceInterval;
@property (nonatomic,strong) UILabel * textLabel;
- (void)startScrollIfNeed;
- (void)animationScroll;
@end

NS_ASSUME_NONNULL_END
