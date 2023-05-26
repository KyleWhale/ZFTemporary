
#import "ZFPresentLogManager.h"

static BOOL kLogEnable = NO;

@implementation ZFPresentLogManager

+ (void)setLogEnable:(BOOL)enable {
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    return kLogEnable;
}

+ (NSString *)version {
    return @"4.1.2";
}

+ (void)logWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    if ([self getLogEnable]) {
    }
}

@end
