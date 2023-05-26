//
//  ZFAdModelProtocol.h
//  ZFInterimCode
//
//  Created by admin on 2023/5/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZFAdModelProtocol <NSObject>

@property (nonatomic, assign) BOOL sub;

@property (nonatomic, copy) NSString *secs;

@property (nonatomic, copy) NSString *close;

@property (nonatomic, assign) BOOL show;

@property (nonatomic, assign) BOOL enter;

@property (nonatomic, copy) void (^remove)(void);

@property (nonatomic, copy) void (^first)(void);

@property (nonatomic, copy) void (^share)(void);

@property (nonatomic, copy) void (^second)(void);

@property (nonatomic, copy) void (^third)(void);

@property (nonatomic, copy) void (^collect)(void);

@property (nonatomic, copy) void (^left)(void);

@property (nonatomic, copy) void (^right)(void);

@property (nonatomic, copy) void (^next)(void);

@end

NS_ASSUME_NONNULL_END
