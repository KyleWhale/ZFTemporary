
#import <UIKit/UIKit.h>
#import "ZFLoadingView.h"

@interface ZFSpeedLaughView : UIView

@property (nonatomic, strong) ZFLoadingView *loadingView;

@property (nonatomic, strong) UILabel *speedTextLabel;

- (void)startAnimating;

- (void)stopAnimating;

@end
