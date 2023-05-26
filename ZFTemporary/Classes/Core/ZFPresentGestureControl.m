

#import "ZFPresentGestureControl.h"

@interface ZFPresentGestureControl ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGR;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGR;
@property (nonatomic) ZFPanDirection panDirection;
@property (nonatomic) ZFPanLocation panLocation;
@property (nonatomic) ZFPanMovingDirection panMovingDirection;
@property (nonatomic, weak) UIView *targetView;

@end

@implementation ZFPresentGestureControl

- (void)addGestureToView:(UIView *)view {
    self.targetView = view;
    self.targetView.multipleTouchEnabled = YES;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.singleTap  requireGestureRecognizerToFail:self.panGR];
    [self.targetView addGestureRecognizer:self.singleTap];
    [self.targetView addGestureRecognizer:self.doubleTap];
    [self.targetView addGestureRecognizer:self.panGR];
    [self.targetView addGestureRecognizer:self.pinchGR];
    [self.targetView addGestureRecognizer:self.longPressGR];
}

- (void)removeGestureToView:(UIView *)view {
    [view removeGestureRecognizer:self.singleTap];
    [view removeGestureRecognizer:self.doubleTap];
    [view removeGestureRecognizer:self.panGR];
    [view removeGestureRecognizer:self.pinchGR];
    [view removeGestureRecognizer:self.longPressGR];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGR) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.targetView];
        CGFloat x = fabs(translation.x);
        CGFloat y = fabs(translation.y);
        if (x < y && self.disablePanMovingDirection & ZFPrimaryStageDisablePanMovingDirectionVertical) {
            return NO;
        } else if (x > y && self.disablePanMovingDirection & ZFPrimaryStageDisablePanMovingDirectionHorizontal) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    ZFPrimaryStageGestureType type = ZFPrimaryStageGestureTypeUnknown;
    if (gestureRecognizer == self.singleTap) type = ZFPrimaryStageGestureTypeSingleTap;
    else if (gestureRecognizer == self.doubleTap) type = ZFPrimaryStageGestureTypeDoubleTap;
    else if (gestureRecognizer == self.panGR) type = ZFPrimaryStageGestureTypePan;
    else if (gestureRecognizer == self.pinchGR) type = ZFPrimaryStageGestureTypePinch;
    CGPoint locationPoint = [touch locationInView:touch.view];
    if (locationPoint.x > _targetView.bounds.size.width / 2) {
        self.panLocation = ZFPanLocationRight;
    } else {
        self.panLocation = ZFPanLocationLeft;
    }
    
    switch (type) {
        case ZFPrimaryStageGestureTypeUnknown: break;
        case ZFPrimaryStageGestureTypePan: {
            if (self.disableTypes & ZFPrimaryStageDisableGestureTypesPan) {
                return NO;
            }
        }
            break;
        case ZFPrimaryStageGestureTypePinch: {
            if (self.disableTypes & ZFPrimaryStageDisableGestureTypesPinch) {
                return NO;
            }
        }
            break;
        case ZFPrimaryStageGestureTypeDoubleTap: {
            if (self.disableTypes & ZFPrimaryStageDisableGestureTypesDoubleTap) {
                return NO;
            }
        }
            break;
        case ZFPrimaryStageGestureTypeSingleTap: {
            if (self.disableTypes & ZFPrimaryStageDisableGestureTypesSingleTap) {
                return NO;
            }
        }
            break;
        case ZFPrimaryStageDisableGestureTypesLongPress: {
            if (self.disableTypes & ZFPrimaryStageDisableGestureTypesLongPress) {
                return NO;
            }
        }
    }
    
    if (self.triggerCondition) return self.triggerCondition(self, type, gestureRecognizer, touch);
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer != self.singleTap &&
        otherGestureRecognizer != self.doubleTap &&
        otherGestureRecognizer != self.panGR &&
        otherGestureRecognizer != self.pinchGR) return NO;
    
    if (gestureRecognizer == self.panGR) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.targetView];
        CGFloat x = fabs(translation.x);
        CGFloat y = fabs(translation.y);
        if (x < y && self.disablePanMovingDirection & ZFPrimaryStageDisablePanMovingDirectionVertical) {
            return YES;
        } else if (x > y && self.disablePanMovingDirection & ZFPrimaryStageDisablePanMovingDirectionHorizontal) {
            return YES;
        }
    }
    if (gestureRecognizer.numberOfTouches >= 2) {
        return NO;
    }
    return YES;
}

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap){
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.delegate = self;
        _singleTap.delaysTouchesBegan = YES;
        _singleTap.delaysTouchesEnded = YES;
        _singleTap.numberOfTouchesRequired = 1;
        _singleTap.numberOfTapsRequired = 1;
    }
    return _singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.delegate = self;
        _doubleTap.delaysTouchesBegan = YES;
        _doubleTap.delaysTouchesEnded = YES;
        _doubleTap.numberOfTouchesRequired = 1;
        _doubleTap.numberOfTapsRequired = 2;
    }
    return _doubleTap;
}

- (UIPanGestureRecognizer *)panGR {
    if (!_panGR) {
        _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGR.delegate = self;
        _panGR.delaysTouchesBegan = YES;
        _panGR.delaysTouchesEnded = YES;
        _panGR.maximumNumberOfTouches = 1;
        _panGR.cancelsTouchesInView = YES;
    }
    return _panGR;
}

- (UIPinchGestureRecognizer *)pinchGR {
    if (!_pinchGR) {
        _pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        _pinchGR.delegate = self;
        _pinchGR.delaysTouchesBegan = YES;
    }
    return _pinchGR;
}

- (UILongPressGestureRecognizer *)longPressGR {
    if (!_longPressGR) {
        _longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _longPressGR.delegate = self;
        _longPressGR.delaysTouchesBegan = YES;
    }
    return _longPressGR;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapped) self.singleTapped(self);
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if (self.doubleTapped) self.doubleTapped(self);
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translate = [pan translationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            self.panMovingDirection = ZFPanMovingDirectionUnkown;
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            if (x > y) {
                self.panDirection = ZFPanDirectionHorizontal;
            } else if (x < y) {
                self.panDirection = ZFPanDirectionVertical;
            } else {
                self.panDirection = ZFPanDirectionUnknown;
            }
            
            if (self.beganPan) self.beganPan(self, self.panDirection, self.panLocation);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            switch (_panDirection) {
                case ZFPanDirectionHorizontal: {
                    if (translate.x > 0) {
                        self.panMovingDirection = ZFPanMovingDirectionRight;
                    } else {
                        self.panMovingDirection = ZFPanMovingDirectionLeft;
                    }
                }
                    break;
                case ZFPanDirectionVertical: {
                    if (translate.y > 0) {
                        self.panMovingDirection = ZFPanMovingDirectionBottom;
                    } else {
                        self.panMovingDirection = ZFPanMovingDirectionTop;
                    }
                }
                    break;
                case ZFPanDirectionUnknown:
                    break;
            }
            if (self.changedPan) self.changedPan(self, self.panDirection, self.panLocation, velocity);
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (self.endedPan) self.endedPan(self, self.panDirection, self.panLocation);
        }
            break;
        default:
            break;
    }
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
    switch (pinch.state) {
        case UIGestureRecognizerStateEnded: {
            if (self.pinched) self.pinched(self, pinch.scale);
        }
            break;
        default:
            break;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            if (self.longPressed) self.longPressed(self, ZFLongPressGestureRecognizerStateBegan);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (self.longPressed) self.longPressed(self, ZFLongPressGestureRecognizerStateChanged);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            if (self.longPressed) self.longPressed(self, ZFLongPressGestureRecognizerStateEnded);
        }
            break;
        default: break;
    }
}

@end
