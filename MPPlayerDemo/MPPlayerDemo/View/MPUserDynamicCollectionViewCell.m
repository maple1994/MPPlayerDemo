//
//  MPUserDynamicCollectionViewCell.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/18.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPUserDynamicCollectionViewCell.h"

@implementation MPUserDynamicCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)setup
{
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImageView.layer.cornerRadius = 40;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.borderWidth = 1;
    self.iconImageView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.iconImageView.frame = CGRectMake(0, 0, 80, 80);
    [self.contentView addSubview:self.iconImageView];
}

@end
