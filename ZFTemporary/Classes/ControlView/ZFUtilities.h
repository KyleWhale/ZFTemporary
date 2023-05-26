

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Masonry.h"

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((NSInteger)(([[UIScreen mainScreen] currentMode].size.height/[[UIScreen mainScreen] currentMode].size.width)*100) == 216) : NO)

#define ZFPrimaryStage_Image(file)                 [ZFUtilities imageNamed:file]

#define ZFPrimaryStage_ScreenWidth                 [[UIScreen mainScreen] bounds].size.width
#define ZFPrimaryStage_ScreenHeight                [[UIScreen mainScreen] bounds].size.height

#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ZFIPhoneX ({\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
if ([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom > 0.0) {\
isPhoneX = YES;\
}\
}\
isPhoneX;\
})

#define ZFNavigationStatusBar (ZFIPhoneX ? 44 : 20)

@interface ZFUtilities : NSObject

+ (NSString *)convertTimeSecond:(NSInteger)timeSecond;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageNamed:(NSString *)name;

@end

