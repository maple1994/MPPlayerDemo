//
//  MPCardStackLayout.h
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPCardStackLayout.h"

@implementation MPCardStackLayout

- (instancetype)init
{
    self = [super init];
    self.itemSize = CGSizeMake(250, 400);
    self.spacing = 4;
    self.maximumVisibleItems = 4;
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    NSAssert(self.collectionView.numberOfSections == 1, @"不支持多个Section");
}

- (CGSize)collectionViewContentSize
{
    if (self.collectionView == nil) {
        return CGSizeZero;
    }
    NSInteger itemsCount = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(self.collectionView.bounds.size.width * itemsCount, self.collectionView.bounds.size.height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if (self.collectionView == nil)
        return nil;
    NSInteger totalItemsCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger tmp = (int)self.collectionView.contentOffset.x / (int)self.collectionView.bounds.size.width;
    NSInteger minVisibleIndex = MAX(0, tmp);
    NSInteger maxVisibleIndex = MIN(totalItemsCount, minVisibleIndex + self.maximumVisibleItems);
    
    CGFloat contentCenterX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width / 2;
    NSInteger deltaOffset = (int)self.collectionView.contentOffset.x % (int)self.collectionView.bounds.size.width;
    CGFloat percentageDeltaOffset = deltaOffset / self.collectionView.bounds.size.width;
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    for (NSInteger i = minVisibleIndex; i < maxVisibleIndex; i++) {
        UICollectionViewLayoutAttributes *attribute = [self conputeLayoutAttributesForItem:[NSIndexPath indexPathForRow:i inSection:0] minVisibleIndex:minVisibleIndex contentCenterX:contentCenterX deltaOffset:deltaOffset percentageDeltaOffset:percentageDeltaOffset];
        [attributes addObject:attribute];
    }
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (UICollectionViewLayoutAttributes *)conputeLayoutAttributesForItem: (NSIndexPath *)indexPath minVisibleIndex: (NSInteger)minVisibleIndex contentCenterX: (CGFloat)contentCenterX deltaOffset: (CGFloat)deltaOffset percentageDeltaOffset: (CGFloat)percentageDeltaOffset {
    if (self.collectionView == nil) {
        return [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    }
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger cardIndex = indexPath.row - minVisibleIndex;
    attributes.size = self.itemSize;
    CGFloat scale = 1.0 - cardIndex * 0.1;
    contentCenterX -= 20;
    // 宽度减少的值
    CGFloat deltaX = self.itemSize.width * cardIndex * 0.1;
    CGFloat centerX = contentCenterX + self.spacing * cardIndex + deltaX;
    CGFloat centerY = CGRectGetMidY(self.collectionView.bounds);
    CGPoint center = CGPointMake(centerX, centerY);
    attributes.zIndex = self.maximumVisibleItems - cardIndex;
    attributes.size = self.itemSize;
    if (cardIndex == 0) {
        center.x -= deltaOffset;
        attributes.transform = CGAffineTransformIdentity;
    }else if (cardIndex >= 1 && cardIndex < self.maximumVisibleItems) {
        scale = scale + percentageDeltaOffset * 0.1;
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
        center.x -= (self.spacing + 0.1 * self.itemSize.width) * percentageDeltaOffset;
        if (cardIndex == self.maximumVisibleItems - 1) {
            attributes.alpha = percentageDeltaOffset;
        }
    }
    attributes.center = center;
    return attributes;
}


// MARK: - Setter
- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    if (self.collectionView != nil) {
        [self invalidateLayout];
    }
}

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    if (self.collectionView != nil) {
        [self invalidateLayout];
    }
}

- (void)setMaximumVisibleItems:(NSInteger)maximumVisibleItems
{
    _maximumVisibleItems = maximumVisibleItems;
    if (self.collectionView != nil) {
        [self invalidateLayout];
    }
}

@end
