//
//  MPWaterFallCollectionViewCell.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/1/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPWaterFallCollectionViewCell.h"
#import <ZFPlayer/UIImageView+ZFCache.h>

@implementation MPWaterFallCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)setup
{
    self.imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.imageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

- (void)setData:(ZFTableData *)data
{
    _data = data;
    [self.imageView setImageWithURLString:data.thumbnail_url placeholder:nil];
}

@end
