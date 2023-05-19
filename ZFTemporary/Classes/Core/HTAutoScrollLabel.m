//
//  HTAutoScrollLabel.m
//  Movie
//
//  Created by wmz on 2023/4/24.
//

#import "HTAutoScrollLabel.h"
#import "ZFUtilities.h"

@implementation HTAutoScrollLabel{
    BOOL hadScroll;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self ht_commonInit];
    }
    return self;
}
 
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self ht_commonInit];
    }
    return self;
}
 
- (void)ht_commonInit {
    self.scrollSpeed = 100 ;
    self.pauseInterval = 2;
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

- (void)ht_startScrollIfNeed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self layoutIfNeeded] ;
    self.contentSize = self.textLabel.frame.size ;
    if ([self canScroll]) {
        hadScroll = YES;
        [self ht_animationScroll];
    }
}


- (void)ht_animationScroll {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ht_animationScroll) object:nil];
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
            [self performSelector:@selector(ht_animationScroll) withObject:nil afterDelay:self.pauseInterval];
        }else{
            self.contentOffset = CGPointZero;
        }
    }];
}

- (BOOL)canScroll{
    return  self.textLabel.frame.size.width > self.frame.size.width;
}
 
@end
