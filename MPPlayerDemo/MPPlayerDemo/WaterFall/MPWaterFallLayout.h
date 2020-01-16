//
//  MPWaterFallLayout.h
//  MPPlayerDemo
//
//  Created by Maple on 2020/1/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPWaterFallLayout;

@protocol MPWaterFallLayoutDataSource <NSObject>

@required
/// 获取item高度，返回itemWidth和indexPath去获取
- (CGFloat)waterFallLayout: (MPWaterFallLayout *)layout itemHeightForItemWidth: (CGFloat)itemWidth atIndexPath: (NSIndexPath *)indexPath;

@end

@interface MPWaterFallLayout : UICollectionViewLayout

@property (nonatomic, weak) id<MPWaterFallLayoutDataSource> dataSource;
/// 根据设置的列数，列间距，返回itemWidth
@property (nonatomic, readonly) CGFloat itemWidth;
/// 总共有多少列，默认为2
@property (nonatomic) NSInteger column;
/// 列间距，默认为0
@property (nonatomic) CGFloat columnSpacing;
/// 行间距
@property (nonatomic) CGFloat rowSpacing;
/// section与collectionView的间距，默认是（0，0，0，0）
@property (nonatomic) UIEdgeInsets sectionInset;

+ (instancetype)waterFallLayoutWithColumn:(NSInteger)column;
- (instancetype)initWIthColumn:(NSInteger)column;


@end

