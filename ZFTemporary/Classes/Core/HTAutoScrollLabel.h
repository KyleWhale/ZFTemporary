//
//  HTAutoScrollLabel.h
//  Movie
//
//  Created by wmz on 2023/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTAutoScrollLabel : UIScrollView
@property(nonatomic) float scrollSpeed;
@property(nonatomic) NSTimeInterval pauseInterval;
@property (nonatomic,strong) UILabel * textLabel ;
- (void)ht_startScrollIfNeed ;
- (void)ht_animationScroll;
@end

NS_ASSUME_NONNULL_END
