//
//  MPCardStackLayout.h
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPCardStackLayout : UICollectionViewLayout

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat spacing;
@property (nonatomic) NSInteger maximumVisibleItems;

@end

NS_ASSUME_NONNULL_END
