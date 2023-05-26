

#import "ZFAutoScrollLabel.h"
#import "ZFUtilities.h"

@implementation ZFAutoScrollLabel{
    BOOL hadScroll;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}
 
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
 
- (void)commonInit {
    self.scrollSpeed = 100 ;
    self.practiceInterval = 2;
    self.scrollEnabled = NO ;
    self.textLabel = UILabel.new;
    self.textLabel.textColor = UIColorFromHex(0xECECEC);
    self.textLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.textLabel];
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
        make.height.equalTo(self.mas_height);
    }];
}

- (void)startScrollIfNeed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self layoutIfNeeded] ;
    self.contentSize = self.textLabel.frame.size ;
    if ([self canScroll]) {
        hadScroll = YES;
        [self animationScroll];
    }
}


- (void)animationScroll {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationScroll) object:nil];
    if(![self canScroll]) return;
    self.contentOffset = CGPointMake(-self.bounds.size.width, 0);
    [UIView animateWithDuration:self.textLabel.frame.size.width/self.scrollSpeed delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if([self canScroll]){
            self.contentOffset = CGPointMake(self.textLabel.frame.size.width - self.bounds.size.width, 0);
        }else{
            self.contentOffset = CGPointZero;
        }
    } completion:^(BOOL finished) {
        if ([self canScroll]) {
            [self performSelector:@selector(animationScroll) withObject:nil afterDelay:self.practiceInterval];
        }else{
            self.contentOffset = CGPointZero;
        }
    }];
}

- (BOOL)canScroll{
    return  self.textLabel.frame.size.width > self.frame.size.width;
}
 
@end
