//
//  MPWaterFallCollectionViewCell.h
//  MPPlayerDemo
//
//  Created by Maple on 2020/1/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFTableData.h"

@interface MPWaterFallCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) ZFTableData *data;

@end

