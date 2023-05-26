

#import <UIKit/UIKit.h>
#import "ZFPrimaryConst.h"

@interface ZFPresentView : UIView

@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, assign) ZFPrimaryStageScalingMode scalingMode;

@property (nonatomic, assign) CGSize verySize;

@property (nonatomic, strong, readonly) UIImageView *coverImageView;

@end
