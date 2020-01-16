//
//  MPWaterFallLayout.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/1/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPWaterFallLayout.h"

@interface MPWaterFallLayout ()
/// 用于记录每一列的最大Y值
@property (nonatomic, strong) NSMutableDictionary *maxYDic;
/// attributes数组
@property (nonatomic, strong) NSMutableArray *attributesArray;

@end

@implementation MPWaterFallLayout

+ (instancetype)waterFallLayoutWithColumn:(NSInteger)column
{
    return [[self alloc] initWIthColumn:column];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.column = 2;
    }
    return self;
}

- (instancetype)initWIthColumn:(NSInteger)column
{
    if (self = [super init]) {
        self.column = column;
    }
    return self;
}

// MARK: - Layout Override 布局必须重写的方法
/// 1、初始化数据源
- (void)prepareLayout
{
    [super prepareLayout];
    [self.attributesArray removeAllObjects];
    // 初始化字典，有几列就有几个键值对，key为列，value为列的最大y值，
    // 初始值为上内边距
    for (int i = 0; i < self.column; i++) {
        self.maxYDic[@(i)] = @(self.sectionInset.top);
    }
    // 获取item总数
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    // 为每个Item创建attributes存入数组中
    for (int i = 0; i < itemCount; i++) {
        // 循环调用2去计算item attribute
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attributesArray addObject:attributes];
    }
}

/// 2、计算每个Attribute
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
     UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSAssert([self.dataSource respondsToSelector:@selector(waterFallLayout:itemHeightForItemWidth:atIndexPath:)], @"you must override waterFallLayout:itemHeightForItemWidth:atIndexPath: methods  - Warning : 需要重写瀑布流的返回高度代理方法!");
    CGFloat itemWidth = self.itemWidth;
    CGFloat itemHeight = [self.dataSource waterFallLayout:self itemHeightForItemWidth:itemWidth atIndexPath:attributes.indexPath];
    
    /// 找出最短的一列
    __block NSNumber *minIndex = @(0);
    [self.maxYDic enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *obj, BOOL * _Nonnull stop) {
        if ([self.maxYDic[minIndex] floatValue] > [obj floatValue]) {
            minIndex = key;
        }
    }];
    // 根据最短列去计算itemX
    CGFloat itemX = self.sectionInset.left + (self.columnSpacing + itemWidth) * minIndex.intValue;
    CGFloat itemY = 0;
    if (self.column == 1) {
        // 一列情况
        if (indexPath.row == 0 ) {
            itemY = [self.maxYDic[minIndex] floatValue];
        }else{
            itemY = [self.maxYDic[minIndex] floatValue] + self.rowSpacing;
        }
    }else{
        // 瀑布流多列情况
        // 第一行Cell不需要添加RowSpacing, 对应的indexPath.row = 0 && =1;
        if (indexPath.row == 0 || indexPath.row == 1) {
            itemY = [self.maxYDic[minIndex] floatValue];
        }else{
            itemY = [self.maxYDic[minIndex] floatValue] + self.rowSpacing;
        }
    }
    attributes.frame = CGRectMake(itemX, itemY , itemWidth, itemHeight);
    // 更新maxY
    self.maxYDic[minIndex] = @(CGRectGetMaxY(attributes.frame));
    return attributes;
}

/// 3、返回数据源
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attributesArray;
}

/// 4、返回itemSize
- (CGSize)collectionViewContentSize
{
    __block NSNumber *maxIndex = @(0);
    // 找到最长的一列
    [self.maxYDic enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *obj, BOOL * _Nonnull stop) {
        if ([self.maxYDic[maxIndex] floatValue] < [obj floatValue]) {
            maxIndex = key;
        }
    }];
    CGFloat contentSizeY = [self.maxYDic[maxIndex] floatValue] + self.sectionInset.bottom;
    return CGSizeMake(self.collectionView.frame.size.width, contentSizeY);
}

// MARK: - Getter & Setter
- (NSMutableDictionary *)maxYDic
{
    if (!_maxYDic) {
        _maxYDic = [[NSMutableDictionary alloc] init];
    }
    return _maxYDic;
}

- (NSMutableArray *)attributesArray
{
    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}

- (CGFloat)itemWidth
{
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    if (collectionViewWidth == 0) {
        collectionViewWidth = [UIScreen mainScreen].bounds.size.width;
    }
    CGFloat itemWidth = (collectionViewWidth - self.sectionInset.left - self.sectionInset.right - (self.column) * self.columnSpacing * (self.column - 1)) / self.column;
    return itemWidth;
}

@end
