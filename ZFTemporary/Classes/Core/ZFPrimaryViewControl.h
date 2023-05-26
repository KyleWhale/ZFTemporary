
#import <Foundation/Foundation.h>
#import "ZFPresentStateWithback.h"
#import "ZFOrientationObserver.h"
#import "ZFPresentGestureControl.h"
#import "ZFReachabilityManager.h"
@class ZFPresentController;

NS_ASSUME_NONNULL_BEGIN

@protocol ZFPrimaryViewControl <NSObject>

@required

@property (nonatomic, weak) ZFPresentController *primaryPretty;

@optional

- (void)veryPractice:(ZFPresentController *)practiceScreen prepareToPlay:(NSURL *)assetUsing;

- (void)veryPractice:(ZFPresentController *)practiceScreen presentPoliteStateChanged:(ZFPrimaryStagePresentState)state;

- (void)veryPractice:(ZFPresentController *)practiceScreen stateLoadChanged:(ZFPrimaryStageLoadState)state;

- (void)veryPractice:(ZFPresentController *)practiceScreen
        currentTime:(NSTimeInterval)currentTime
          tableTime:(NSTimeInterval)tableTime;

- (void)veryPractice:(ZFPresentController *)practiceScreen
         presentTime:(NSTimeInterval)presentTime;

- (void)veryPractice:(ZFPresentController *)practiceScreen
       draggingTime:(NSTimeInterval)sleepTime
          tableTime:(NSTimeInterval)tableTime;

- (void)veryPracticePointEnd:(ZFPresentController *)practiceScreen;

- (void)veryPracticePointFailed:(ZFPresentController *)practiceScreen error:(id)error;

- (void)lockedVeryPractice:(ZFPresentController *)practiceScreen practiced:(BOOL)locked;

- (void)veryPractice:(ZFPresentController *)practiceScreen orientationWillChange:(ZFOrientationObserver *)observer;

- (void)veryPractice:(ZFPresentController *)practiceScreen orientationDidChanged:(ZFOrientationObserver *)observer;

#pragma mark - The network changed

- (void)veryPractice:(ZFPresentController *)practiceScreen reachabilityChanged:(ZFReachabilityStatus)status;

- (void)veryPractice:(ZFPresentController *)practiceScreen presentChangedSize:(CGSize)size;

- (BOOL)gestureTriggerCondition:(ZFPresentGestureControl *)gestureControl
                    gestureType:(ZFPrimaryStageGestureType)gestureType
              gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                          touch:(UITouch *)touch;

- (void)gestureSingleTapped:(ZFPresentGestureControl *)gestureControl;

- (void)gestureDoubleTapped:(ZFPresentGestureControl *)gestureControl;

- (void)gestureBeganPan:(ZFPresentGestureControl *)gestureControl
           panDirection:(ZFPanDirection)direction
            panLocation:(ZFPanLocation)location;

- (void)gestureChangedPan:(ZFPresentGestureControl *)gestureControl
             panDirection:(ZFPanDirection)direction
              panLocation:(ZFPanLocation)location
             withVelocity:(CGPoint)velocity;

- (void)gestureEndedPan:(ZFPresentGestureControl *)gestureControl
           panDirection:(ZFPanDirection)direction
            panLocation:(ZFPanLocation)location;

- (void)gesturePinched:(ZFPresentGestureControl *)gestureControl
                 scale:(float)scale;

- (void)longPressed:(ZFPresentGestureControl *)gestureControl state:(ZFLongPressGestureRecognizerState)state;

#pragma mark - scrollview

- (void)playerWillAppearInScrollView:(ZFPresentController *)practiceScreen;

- (void)primaryStageDidAppearInScrollView:(ZFPresentController *)practiceScreen;

- (void)playerWillDisappearInScrollView:(ZFPresentController *)practiceScreen;

- (void)primaryStageDidDisappearInScrollView:(ZFPresentController *)practiceScreen;

- (void)playerAppearingInScrollView:(ZFPresentController *)practiceScreen playerApperaPercent:(CGFloat)playerApperaPercent;

- (void)playerDisappearingInScrollView:(ZFPresentController *)practiceScreen playerDisapperaPercent:(CGFloat)playerDisapperaPercent;

- (void)veryPractice:(ZFPresentController *)practiceScreen floatViewShow:(BOOL)show;

@end

NS_ASSUME_NONNULL_END

