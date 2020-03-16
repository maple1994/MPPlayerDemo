//
//  MPCardLayoutCell.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPCardLayoutCell.h"

@implementation MPCardLayoutCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.coverImageView];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.coverImageView.frame = self.bounds;
}


@end
