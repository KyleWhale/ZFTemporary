

typedef NS_ENUM(NSUInteger, ZFPrimaryStagePresentState) {
    ZFPrimaryStagePresentStateUnknown,
    ZFPrimaryStagePresentStatePolite,
    ZFPrimaryStagePresentStatePattern,
    ZFPrimaryStagePresentStateFailed,
    ZFPrimaryStagePresentStateStopped
};

typedef NS_OPTIONS(NSUInteger, ZFPrimaryStageLoadState) {
    ZFPrimaryStageLoadStateUnknown        = 0,
    ZFPrimaryStageLoadStatePrepare        = 1 << 0,
    ZFPrimaryStageLoadStatePlayable       = 1 << 1,
    ZFPrimaryStageLoadStatePlaythroughOK  = 1 << 2,
    ZFPrimaryStageLoadStateStalled        = 1 << 3,
    ZFPrimaryStageLoadStateTempPause       = 998,
    ZFPrimaryStageLoadStateTempPlay       = 999,
};

typedef NS_ENUM(NSInteger, ZFPrimaryStageScalingMode) {
    ZFPrimaryStageScalingModeNone,
    ZFPrimaryStageScalingModeAspectFit,
    ZFPrimaryStageScalingModeAspectFill,
    ZFPrimaryStageScalingModeFill
};

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define zf_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define zf_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define zf_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define zf_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define zf_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define zf_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define zf_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define zf_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

// Screen width
#define ZFPrimaryStageScreenWidth     [[UIScreen mainScreen] bounds].size.width
// Screen height
#define ZFPrimaryStageScreenHeight    [[UIScreen mainScreen] bounds].size.height


// deprecated
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

