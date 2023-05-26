

#import <UIKit/UIKit.h>

typedef void (^ZFDownLoadDataCallBack)(NSData *data, NSError *error);
typedef void (^ZFDownloadProgressBlock)(unsigned long long total, unsigned long long current);

@interface ZFImageDownloader : NSObject<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic, assign) unsigned long long currentLength;

@property (nonatomic, copy) ZFDownloadProgressBlock progressBlock;
@property (nonatomic, copy) ZFDownLoadDataCallBack callbackOnFinished;

- (void)startDownloadImageWithUrl:(NSString *)url
                         progress:(ZFDownloadProgressBlock)progress
                         finished:(ZFDownLoadDataCallBack)finished;

@end

typedef void (^ZFImageBlock)(UIImage *image);

@interface UIImageView (ZFCache)

@property (nonatomic, copy) ZFImageBlock completion;

@property (nonatomic, strong) ZFImageDownloader *imageDownloader;

@property (nonatomic, assign) NSUInteger attemptToReloadTimesForFailedURL;

@property (nonatomic, assign) BOOL shouldAutoClipImageToViewSize;

- (void)setImageWithURLString:(NSString *)url placeholderImageName:(NSString *)placeholderImageName;

- (void)setImageWithURLString:(NSString *)url placeholder:(UIImage *)placeholderImage;

- (void)setImageWithURLString:(NSString *)url
                  placeholder:(UIImage *)placeholderImage
                   completion:(void (^)(UIImage *image))completion;

- (void)setImageWithURLString:(NSString *)url
         placeholderImageName:(NSString *)placeholderImageName
                   completion:(void (^)(UIImage *image))completion;
@end
