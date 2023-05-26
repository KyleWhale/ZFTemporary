
#import "UIScrollView+conditions.h"
#import <objc/runtime.h>
#import "ZFReachabilityManager.h"
#import "ZFPrimaryConst.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface UIScrollView ()

@property (nonatomic) CGFloat zf_lastOffsetY;
@property (nonatomic) CGFloat zf_lastOffsetX;
@property (nonatomic) ZFPrimaryStageScrollDirection zf_scrollDirection;

@end

@implementation UIScrollView (conditions)

- (UIView *)zf_getCellForIndexPath:(NSIndexPath *)indexPath {
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        return cell;
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (NSIndexPath *)zf_getIndexPathForCell:(UIView *)cell {
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)cell];
        return indexPath;
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        NSIndexPath *indexPath = [collectionView indexPathForCell:(UICollectionViewCell *)cell];
        return indexPath;
    }
    return nil;
}

- (void)zf_scrollToRowAtIndexPath:(NSIndexPath *)indexPath
                 atScrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                         animated:(BOOL)animated
                completionHandler:(void (^ __nullable)(void))completionHandler {
    [self zf_scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animateDuration:animated ? 0.4 : 0.0 completionHandler:completionHandler];
}

- (void)zf_scrollToRowAtIndexPath:(NSIndexPath *)indexPath
                 atScrollPosition:(ZFPrimaryStageScrollViewScrollPosition)scrollPosition
                  animateDuration:(NSTimeInterval)duration
                completionHandler:(void (^ __nullable)(void))completionHandler {
    BOOL animated = duration > 0.0;
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        UITableViewScrollPosition tableScrollPosition = UITableViewScrollPositionNone;
        if (scrollPosition <= ZFPrimaryStageScrollViewScrollPositionBottom) {
            tableScrollPosition = (UITableViewScrollPosition)scrollPosition;
        }
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:tableScrollPosition animated:animated];
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        if (self.zf_scrollViewDirection == ZFPrimaryStageScrollViewDirectionVertical) {
            UICollectionViewScrollPosition collectionScrollPosition = UICollectionViewScrollPositionNone;
            switch (scrollPosition) {
                case ZFPrimaryStageScrollViewScrollPositionNone:
                    collectionScrollPosition = UICollectionViewScrollPositionNone;
                    break;
                case ZFPrimaryStageScrollViewScrollPositionTop:
                    collectionScrollPosition = UICollectionViewScrollPositionTop;
                    break;
                case ZFPrimaryStageScrollViewScrollPositionCenteredVertically:
                    collectionScrollPosition = UICollectionViewScrollPositionCenteredVertically;
                    break;
                case ZFPrimaryStageScrollViewScrollPositionBottom:
                    collectionScrollPosition = UICollectionViewScrollPositionBottom;
                    break;
                default:
                    break;
            }
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:collectionScrollPosition animated:animated];
        } else if (self.zf_scrollViewDirection == ZFPrimaryStageScrollViewDirectionHorizontal) {
            UICollectionViewScrollPosition collectionScrollPosition = UICollectionViewScrollPositionNone;
            switch (scrollPosition) {
                case ZFPrimaryStageScrollViewScrollPositionNone:
                    collectionScrollPosition = UICollectionViewScrollPositionNone;
                    break;
                case ZFPrimaryStageScrollViewScrollPositionLeft:
                    collectionScrollPosition = UICollectionViewScrollPositionLeft;
                    break;
                case ZFPrimaryStageScrollViewScrollPositionCenteredHorizontally:
                    collectionScrollPosition = UICollectionViewScrollPositionCenteredHorizontally;
                    break;
                case ZFPrimaryStageScrollViewScrollPositionRight:
                    collectionScrollPosition = UICollectionViewScrollPositionRight;
                    break;
                default:
                    break;
            }
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:collectionScrollPosition animated:animated];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) completionHandler();
    });
}

- (void)zf_scrollViewDidEndDecelerating {
    BOOL scrollToScrollStop = !self.tracking && !self.dragging && !self.decelerating;
    if (scrollToScrollStop) {
        [self _scrollViewDidStopScroll];
    }
}

- (void)zf_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = self.tracking && !self.dragging && !self.decelerating;
        if (dragToDragStop) {
            [self _scrollViewDidStopScroll];
        }
    }
}

- (void)zf_scrollViewDidScrollToTop {
    [self _scrollViewDidStopScroll];
}

- (void)zf_scrollViewDidScroll {
    if (self.zf_scrollViewDirection == ZFPrimaryStageScrollViewDirectionVertical) {
        [self _findCorrectCellWhenScrollViewDirectionVertical:nil];
        [self _scrollViewScrollingDirectionVertical];
    } else {
        [self _findCorrectCellWhenScrollViewDirectionHorizontal:nil];
        [self _scrollViewScrollingDirectionHorizontal];
    }
}

- (void)zf_scrollViewWillBeginDragging {
    [self _scrollViewBeginDragging];
}

- (void)_scrollViewDidStopScroll {
    self.zf_scrollDirection = ZFPrimaryStageScrollDirectionNone;
    @zf_weakify(self)
    [self zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (self.zf_scrollViewDidStopScrollCallback) self.zf_scrollViewDidStopScrollCallback(indexPath);
        if (self.zf_scrollViewDidEndScrollingCallback) self.zf_scrollViewDidEndScrollingCallback(indexPath);
    }];
}

- (void)_scrollViewBeginDragging {
    if (self.zf_scrollViewDirection == ZFPrimaryStageScrollViewDirectionVertical) {
        self.zf_lastOffsetY = self.contentOffset.y;
    } else {
        self.zf_lastOffsetX = self.contentOffset.x;
    }
}

- (void)_scrollViewScrollingDirectionVertical {
    CGFloat offsetY = self.contentOffset.y;
    self.zf_scrollDirection = (offsetY - self.zf_lastOffsetY > 0) ? ZFPrimaryStageScrollDirectionUp : ZFPrimaryStageScrollDirectionDown;
    self.zf_lastOffsetY = offsetY;
    if (self.zf_stopPlay) return;
    
    UIView *playerView;
    if (self.zf_containerType == ZFPrimaryStageContainerTypeCell) {
        if (self.contentOffset.y < 0) return;
        if (!self.zf_playingIndexPath) return;
        
        UIView *cell = [self zf_getCellForIndexPath:self.zf_playingIndexPath];
        if (!cell) {
            if (self.presentStateDidDisappearInScrollView) self.presentStateDidDisappearInScrollView(self.zf_playingIndexPath);
            return;
        }
        playerView = [cell viewWithTag:self.zf_containerViewTag];
    } else if (self.zf_containerType == ZFPrimaryStageContainerTypeView) {
        if (!self.zf_containerView) return;
        playerView = self.zf_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
    CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
    CGFloat contentInsetHeight = CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.zf_scrollDirection == ZFPrimaryStageScrollDirectionUp) {
        if (topSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -topSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.presentStateDisappearingInScrollView) self.presentStateDisappearingInScrollView(self.zf_playingIndexPath, playerDisapperaPercent);
        }
        
        if (topSpacing <= 0 && topSpacing > -CGRectGetHeight(rect)/2) {
            if (self.presentStateWillDisappearInScrollView) self.presentStateWillDisappearInScrollView(self.zf_playingIndexPath);
        } else if (topSpacing <= -CGRectGetHeight(rect)) {
            if (self.presentStateDidDisappearInScrollView) self.presentStateDidDisappearInScrollView(self.zf_playingIndexPath);
        } else if (topSpacing > 0 && topSpacing <= contentInsetHeight) {
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(topSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.presentStateAppearingInScrollView) self.presentStateAppearingInScrollView(self.zf_playingIndexPath, playerApperaPercent);
            }
            if (topSpacing <= contentInsetHeight && topSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                if (self.presentStateWillAppearInScrollView) self.presentStateWillAppearInScrollView(self.zf_playingIndexPath);
            } else {
                if (self.presentStateDidAppearInScrollView) self.presentStateDidAppearInScrollView(self.zf_playingIndexPath);
            }
        }
        
    } else if (self.zf_scrollDirection == ZFPrimaryStageScrollDirectionDown) { /// Scroll Down
        if (bottomSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -bottomSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.presentStateDisappearingInScrollView) self.presentStateDisappearingInScrollView(self.zf_playingIndexPath, playerDisapperaPercent);
        }
        
        if (bottomSpacing <= 0 && bottomSpacing > -CGRectGetHeight(rect)/2) {
            if (self.presentStateWillDisappearInScrollView) self.presentStateWillDisappearInScrollView(self.zf_playingIndexPath);
        } else if (bottomSpacing <= -CGRectGetHeight(rect)) {
            if (self.presentStateDidDisappearInScrollView) self.presentStateDidDisappearInScrollView(self.zf_playingIndexPath);
        } else if (bottomSpacing > 0 && bottomSpacing <= contentInsetHeight) {
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(bottomSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.presentStateAppearingInScrollView) self.presentStateAppearingInScrollView(self.zf_playingIndexPath, playerApperaPercent);
            }
            if (bottomSpacing <= contentInsetHeight && bottomSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                if (self.presentStateWillAppearInScrollView) self.presentStateWillAppearInScrollView(self.zf_playingIndexPath);
            } else {
                if (self.presentStateDidAppearInScrollView) self.presentStateDidAppearInScrollView(self.zf_playingIndexPath);
            }
        }
    }
}

- (void)_scrollViewScrollingDirectionHorizontal {
    CGFloat offsetX = self.contentOffset.x;
    self.zf_scrollDirection = (offsetX - self.zf_lastOffsetX > 0) ? ZFPrimaryStageScrollDirectionLeft : ZFPrimaryStageScrollDirectionRight;
    self.zf_lastOffsetX = offsetX;
    if (self.zf_stopPlay) return;
    
    UIView *playerView;
    if (self.zf_containerType == ZFPrimaryStageContainerTypeCell) {
        if (self.contentOffset.x < 0) return;
        if (!self.zf_playingIndexPath) return;
        
        UIView *cell = [self zf_getCellForIndexPath:self.zf_playingIndexPath];
        if (!cell) {
            if (self.presentStateDidDisappearInScrollView) self.presentStateDidDisappearInScrollView(self.zf_playingIndexPath);
            return;
        }
       playerView = [cell viewWithTag:self.zf_containerViewTag];
    } else if (self.zf_containerType == ZFPrimaryStageContainerTypeView) {
        if (!self.zf_containerView) return;
        playerView = self.zf_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
    CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
    CGFloat contentInsetWidth = CGRectGetMaxX(self.frame) - CGRectGetMinX(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.zf_scrollDirection == ZFPrimaryStageScrollDirectionLeft) { /// Scroll left
        if (leftSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -leftSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.presentStateDisappearingInScrollView) self.presentStateDisappearingInScrollView(self.zf_playingIndexPath, playerDisapperaPercent);
        }
        
        if (leftSpacing <= 0 && leftSpacing > -CGRectGetWidth(rect)/2) {
            if (self.presentStateWillDisappearInScrollView) self.presentStateWillDisappearInScrollView(self.zf_playingIndexPath);
        } else if (leftSpacing <= -CGRectGetWidth(rect)) {
            if (self.presentStateDidDisappearInScrollView) self.presentStateDidDisappearInScrollView(self.zf_playingIndexPath);
        } else if (leftSpacing > 0 && leftSpacing <= contentInsetWidth) {
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(leftSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.presentStateAppearingInScrollView) self.presentStateAppearingInScrollView(self.zf_playingIndexPath, playerApperaPercent);
            }
            if (leftSpacing <= contentInsetWidth && leftSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                if (self.presentStateWillAppearInScrollView) self.presentStateWillAppearInScrollView(self.zf_playingIndexPath);
            } else {
                if (self.presentStateDidAppearInScrollView) self.presentStateDidAppearInScrollView(self.zf_playingIndexPath);
            }
        }
        
    } else if (self.zf_scrollDirection == ZFPrimaryStageScrollDirectionRight) {
        if (rightSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -rightSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.presentStateDisappearingInScrollView) self.presentStateDisappearingInScrollView(self.zf_playingIndexPath, playerDisapperaPercent);
        }
        
        if (rightSpacing <= 0 && rightSpacing > -CGRectGetWidth(rect)/2) {
            if (self.presentStateWillDisappearInScrollView) self.presentStateWillDisappearInScrollView(self.zf_playingIndexPath);
        } else if (rightSpacing <= -CGRectGetWidth(rect)) {
            if (self.presentStateDidDisappearInScrollView) self.presentStateDidDisappearInScrollView(self.zf_playingIndexPath);
        } else if (rightSpacing > 0 && rightSpacing <= contentInsetWidth) {
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(rightSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.presentStateAppearingInScrollView) self.presentStateAppearingInScrollView(self.zf_playingIndexPath, playerApperaPercent);
            }
            if (rightSpacing <= contentInsetWidth && rightSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                if (self.presentStateWillAppearInScrollView) self.presentStateWillAppearInScrollView(self.zf_playingIndexPath);
            } else {
                if (self.presentStateDidAppearInScrollView) self.presentStateDidAppearInScrollView(self.zf_playingIndexPath);
            }
        }
    }
}

- (void)_findCorrectCellWhenScrollViewDirectionVertical:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.shouldPractice) return;
    if (self.zf_containerType == ZFPrimaryStageContainerTypeView) return;

    if (!self.zf_stopWhileNotVisible) {
        if (self.zf_playingIndexPath) {
            NSIndexPath *finalIndexPath = self.zf_playingIndexPath;
            if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(finalIndexPath);
            if (handler) handler(finalIndexPath);
            self.zf_shouldPlayIndexPath = finalIndexPath;
            return;
        }
    }
    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    BOOL isLast = self.contentOffset.y + self.frame.size.height >= self.contentSize.height;
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if ((self.contentOffset.y <= 0 || isLast) && (!self.zf_playingIndexPath || [indexPath compare:self.zf_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.zf_containerViewTag];
            if (playerView && !playerView.hidden && playerView.alpha > 0.01) {
                if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.zf_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        indexPath = isLast ? sortedIndexPaths.lastObject : sortedIndexPaths.firstObject;
        if ((self.contentOffset.y <= 0 || isLast) && (!self.zf_playingIndexPath || [indexPath compare:self.zf_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.zf_containerViewTag];
            if (playerView && !playerView.hidden && playerView.alpha > 0.01) {
                if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.zf_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.zf_scrollDirection == ZFPrimaryStageScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    CGFloat scrollViewMidY = CGRectGetHeight(self.frame)/2;
    __block NSIndexPath *finalIndexPath = nil;
    __block CGFloat finalSpace = 0;
    @zf_weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @zf_strongify(self)
        UIView *playerView = [cell viewWithTag:self.zf_containerViewTag];
        if (!playerView || playerView.hidden || playerView.alpha <= 0.01) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
        CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidY - CGRectGetMidY(rect));
        NSIndexPath *indexPath = [self zf_getIndexPathForCell:cell];
        
        if ((topSpacing >= -(1 - self.presentStateApperaPercent) * CGRectGetHeight(rect)) && (bottomSpacing >= -(1 - self.presentStateApperaPercent) * CGRectGetHeight(rect))) {
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];
    if (finalIndexPath) {
        if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(indexPath);
        if (handler) handler(finalIndexPath);
    }
    self.zf_shouldPlayIndexPath = finalIndexPath;
}

- (void)_findCorrectCellWhenScrollViewDirectionHorizontal:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.shouldPractice) return;
    if (self.zf_containerType == ZFPrimaryStageContainerTypeView) return;
    if (!self.zf_stopWhileNotVisible) {
        if (self.zf_playingIndexPath) {
            NSIndexPath *finalIndexPath = self.zf_playingIndexPath;
            if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(finalIndexPath);
            if (handler) handler(finalIndexPath);
            self.zf_shouldPlayIndexPath = finalIndexPath;
            return;
        }
    }
    
    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    BOOL isLast = self.contentOffset.x + self.frame.size.width >= self.contentSize.width;
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if ((self.contentOffset.x <= 0 || isLast) && (!self.zf_playingIndexPath || [indexPath compare:self.zf_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.zf_containerViewTag];
            if (playerView && !playerView.hidden && playerView.alpha > 0.01) {
                if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.zf_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        indexPath = isLast ? sortedIndexPaths.lastObject : sortedIndexPaths.firstObject;
        if ((self.contentOffset.x <= 0 || isLast) && (!self.zf_playingIndexPath || [indexPath compare:self.zf_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.zf_containerViewTag];
            if (playerView && !playerView.hidden && playerView.alpha > 0.01) {
                if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.zf_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.zf_scrollDirection == ZFPrimaryStageScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    CGFloat scrollViewMidX = CGRectGetWidth(self.frame)/2;
    __block NSIndexPath *finalIndexPath = nil;
    __block CGFloat finalSpace = 0;
    @zf_weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @zf_strongify(self)
        UIView *playerView = [cell viewWithTag:self.zf_containerViewTag];
        if (!playerView || playerView.hidden || playerView.alpha <= 0.01) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
        CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidX - CGRectGetMidX(rect));
        NSIndexPath *indexPath = [self zf_getIndexPathForCell:cell];
        
        if ((leftSpacing >= -(1 - self.presentStateApperaPercent) * CGRectGetWidth(rect)) && (rightSpacing >= -(1 - self.presentStateApperaPercent) * CGRectGetWidth(rect))) {
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];

    if (finalIndexPath) {
        if (self.zf_scrollViewDidScrollCallback) self.zf_scrollViewDidScrollCallback(indexPath);
        if (handler) handler(finalIndexPath);
        self.zf_shouldPlayIndexPath = finalIndexPath;
    }
}

- (BOOL)_isTableView {
    return [self isKindOfClass:[UITableView class]];
}

- (BOOL)_isCollectionView {
    return [self isKindOfClass:[UICollectionView class]];
}

#pragma mark - getter

- (ZFPrimaryStageScrollDirection)zf_scrollDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (ZFPrimaryStageScrollViewDirection)zf_scrollViewDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (CGFloat)zf_lastOffsetY {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)zf_lastOffsetX {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

#pragma mark - setter

- (void)setZf_scrollDirection:(ZFPrimaryStageScrollDirection)zf_scrollDirection {
    objc_setAssociatedObject(self, @selector(zf_scrollDirection), @(zf_scrollDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_scrollViewDirection:(ZFPrimaryStageScrollViewDirection)zf_scrollViewDirection {
    objc_setAssociatedObject(self, @selector(zf_scrollViewDirection), @(zf_scrollViewDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_lastOffsetY:(CGFloat)zf_lastOffsetY {
    objc_setAssociatedObject(self, @selector(zf_lastOffsetY), @(zf_lastOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_lastOffsetX:(CGFloat)zf_lastOffsetX {
    objc_setAssociatedObject(self, @selector(zf_lastOffsetX), @(zf_lastOffsetX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIScrollView (ZFPrimaryStageCannotCalled)

- (void)zf_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (self.zf_scrollViewDirection == ZFPrimaryStageScrollViewDirectionVertical) {
        [self _findCorrectCellWhenScrollViewDirectionVertical:handler];
    } else {
        [self _findCorrectCellWhenScrollViewDirectionHorizontal:handler];
    }
}

- (void)zf_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.shouldPractice) return;
    @zf_weakify(self)
    [self zf_filterShouldPlayCellWhileScrolling:^(NSIndexPath *indexPath) {
        @zf_strongify(self)
        if (self.zf_viewControllerDisappear) return;
        if ([ZFReachabilityManager sharedManager].isReachableViaWWAN && !self.zf_WWANAutoPlay) {
            self.zf_shouldPlayIndexPath = indexPath;
            return;
        }
        if (handler) handler(indexPath);
        self.zf_playingIndexPath = indexPath;
    }];
}

#pragma mark - getter

- (void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateDisappearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateAppearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateDidAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateWillDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateWillAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateDidDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidEndScrollingCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidScrollCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))presentStateShouldPlayInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGFloat)presentStateApperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)presentStateDisapperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (BOOL)zf_viewControllerDisappear {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)zf_stopPlay {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.zf_stopPlay = YES;
    return YES;
}

- (BOOL)zf_stopWhileNotVisible {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (NSIndexPath *)zf_playingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSIndexPath *)zf_shouldPlayIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSInteger)zf_containerViewTag {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)zf_isWWANAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)shouldPractice {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.shouldPractice = YES;
    return YES;
}

- (ZFPrimaryStageContainerType)zf_containerType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (UIView *)zf_containerView {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - setter

- (void)setPresentStateDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateDisappearingInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateDisappearingInScrollView), presentStateDisappearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateAppearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))presentStateAppearingInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateAppearingInScrollView), presentStateAppearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateDidAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateDidAppearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateDidAppearInScrollView), presentStateDidAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateWillDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateWillDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateWillDisappearInScrollView), presentStateWillDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateWillAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateWillAppearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateWillAppearInScrollView), presentStateWillAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateDidDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateDidDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateDidDisappearInScrollView), presentStateDidDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setZf_scrollViewDidEndScrollingCallback:(void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidEndScrollingCallback {
    objc_setAssociatedObject(self, @selector(zf_scrollViewDidEndScrollingCallback), zf_scrollViewDidEndScrollingCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setZf_scrollViewDidScrollCallback:(void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidScrollCallback {
    objc_setAssociatedObject(self, @selector(zf_scrollViewDidScrollCallback), zf_scrollViewDidScrollCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateShouldPlayInScrollView:(void (^)(NSIndexPath * _Nonnull))presentStateShouldPlayInScrollView {
    objc_setAssociatedObject(self, @selector(presentStateShouldPlayInScrollView), presentStateShouldPlayInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateApperaPercent:(CGFloat)presentStateApperaPercent {
    objc_setAssociatedObject(self, @selector(presentStateApperaPercent), @(presentStateApperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setPresentStateDisapperaPercent:(CGFloat)presentStateDisapperaPercent {
    objc_setAssociatedObject(self, @selector(presentStateDisapperaPercent), @(presentStateDisapperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setZf_viewControllerDisappear:(BOOL)zf_viewControllerDisappear {
    objc_setAssociatedObject(self, @selector(zf_viewControllerDisappear), @(zf_viewControllerDisappear), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setZf_stopPlay:(BOOL)zf_stopPlay {
    objc_setAssociatedObject(self, @selector(zf_stopPlay), @(zf_stopPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_stopWhileNotVisible:(BOOL)zf_stopWhileNotVisible {
    objc_setAssociatedObject(self, @selector(zf_stopWhileNotVisible), @(zf_stopWhileNotVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_playingIndexPath:(NSIndexPath *)zf_playingIndexPath {
    objc_setAssociatedObject(self, @selector(zf_playingIndexPath), zf_playingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (zf_playingIndexPath && [zf_playingIndexPath compare:self.zf_shouldPlayIndexPath] != NSOrderedSame) {
        self.zf_shouldPlayIndexPath = zf_playingIndexPath;
    }
}

- (void)setZf_shouldPlayIndexPath:(NSIndexPath *)zf_shouldPlayIndexPath {
    if (self.presentStateShouldPlayInScrollView) self.presentStateShouldPlayInScrollView(zf_shouldPlayIndexPath);
    if (self.zf_shouldPlayIndexPathCallback) self.zf_shouldPlayIndexPathCallback(zf_shouldPlayIndexPath);
    objc_setAssociatedObject(self, @selector(zf_shouldPlayIndexPath), zf_shouldPlayIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_containerViewTag:(NSInteger)zf_containerViewTag {
    objc_setAssociatedObject(self, @selector(zf_containerViewTag), @(zf_containerViewTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_containerType:(ZFPrimaryStageContainerType)zf_containerType {
    objc_setAssociatedObject(self, @selector(zf_containerType), @(zf_containerType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_containerView:(UIView *)zf_containerView {
    objc_setAssociatedObject(self, @selector(zf_containerView), zf_containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setShouldPractice:(BOOL)shouldPractice {
    objc_setAssociatedObject(self, @selector(shouldPractice), @(shouldPractice), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setZf_WWANAutoPlay:(BOOL)zf_WWANAutoPlay {
    objc_setAssociatedObject(self, @selector(zf_isWWANAutoPlay), @(zf_WWANAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UIScrollView (ZFPrimaryStageDeprecated)

#pragma mark - getter

- (void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidStopScrollCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))zf_shouldPlayIndexPathCallback {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - setter

- (void)setZf_scrollViewDidStopScrollCallback:(void (^)(NSIndexPath * _Nonnull))zf_scrollViewDidStopScrollCallback {
    objc_setAssociatedObject(self, @selector(zf_scrollViewDidStopScrollCallback), zf_scrollViewDidStopScrollCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setZf_shouldPlayIndexPathCallback:(void (^)(NSIndexPath * _Nonnull))zf_shouldPlayIndexPathCallback {
    objc_setAssociatedObject(self, @selector(zf_shouldPlayIndexPathCallback), zf_shouldPlayIndexPathCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - method

- (void)zf_scrollToRowAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^ __nullable)(void))completionHandler {
    [self zf_scrollToRowAtIndexPath:indexPath animated:YES completionHandler:completionHandler];
}

- (void)zf_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler {
    [self zf_scrollToRowAtIndexPath:indexPath animateWithDuration:animated ? 0.4 : 0.0 completionHandler:completionHandler];
}

- (void)zf_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animateWithDuration:(NSTimeInterval)duration completionHandler:(void (^ __nullable)(void))completionHandler {
    [self zf_scrollToRowAtIndexPath:indexPath atScrollPosition:ZFPrimaryStageScrollViewScrollPositionTop animateDuration:duration completionHandler:completionHandler];
}

@end

#pragma clang diagnostic pop
