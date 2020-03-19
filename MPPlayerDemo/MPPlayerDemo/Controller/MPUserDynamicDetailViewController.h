//
//  MPUserDynamicDetailViewController.h
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/18.
//  Copyright © 2020 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPUserDynamicDetailViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger totalCount;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImageView *startImageView;
@property (nonatomic, strong) UICollectionViewCell *startCell;

@end

NS_ASSUME_NONNULL_END
