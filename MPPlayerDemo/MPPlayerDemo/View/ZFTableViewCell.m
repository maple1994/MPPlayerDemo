//
//  ZFTableViewCell.m
//  ZFPlayer
//
//  Created by 紫枫 on 2018/4/3.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFTableViewCell.h"
#import <ZFPlayer/UIImageView+ZFCache.h>

@interface ZFTableViewCell ()
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIView *fullMaskView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) id<ZFTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *bgImgView;

@property (nonatomic, strong) UIView *effectView;

@end

@implementation ZFTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nickNameLabel];
        [self.contentView addSubview:self.bgImgView];
        [self.bgImgView addSubview:self.effectView];
        [self.contentView addSubview:self.coverImageView];
        [self.coverImageView addSubview:self.playBtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.fullMaskView];
        self.contentView.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setLayout:(ZFTableViewCellLayout *)layout {
    _layout = layout;
    self.headImageView.frame = layout.headerRect;
    self.nickNameLabel.frame = layout.nickNameRect;
    self.coverImageView.frame = layout.videoRect;
    self.bgImgView.frame = layout.videoRect;
    self.effectView.frame = self.bgImgView.bounds;
    self.titleLabel.frame = layout.titleLabelRect;
    self.playBtn.frame = layout.playBtnRect;
    self.fullMaskView.frame = layout.maskViewRect;
    
    [self.headImageView setImageWithURLString:layout.data.head placeholder:[UIImage imageNamed:@"defaultUserIcon"]];
    [self.coverImageView setImageWithURLString:layout.data.thumbnail_url placeholder:[UIImage imageNamed:@"loading_bgView"]];
    [self.bgImgView setImageWithURLString:layout.data.thumbnail_url placeholder:[UIImage imageNamed:@"loading_bgView"]];
    self.nickNameLabel.text = layout.data.nick_name;
    self.titleLabel.text = layout.data.title;
}

- (void)setDelegate:(id<ZFTableViewCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath {
    self.delegate = delegate;
    self.indexPath = indexPath;
}

- (void)setNormalMode {
    self.fullMaskView.hidden = YES;
    self.titleLabel.textColor = [UIColor blackColor];
    self.nickNameLabel.textColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)showMaskView {
    [UIView animateWithDuration:0.3 animations:^{
        self.fullMaskView.alpha = 1;
    }];
}

- (void)hideMaskView {
    [UIView animateWithDuration:0.3 animations:^{
        self.fullMaskView.alpha = 0;
    }];
}


- (void)playBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(zf_playTheVideoAtIndexPath:)]) {
        [self.delegate zf_playTheVideoAtIndexPath:self.indexPath];
    }
}

#pragma mark - getter

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"new_allPlay_44x44_"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIView *)fullMaskView {
    if (!_fullMaskView) {
        _fullMaskView = [UIView new];
        _fullMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _fullMaskView.userInteractionEnabled = NO;
    }
    return _fullMaskView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [UILabel new];
        _nickNameLabel.textColor = [UIColor whiteColor];
        _nickNameLabel.font = [UIFont systemFontOfSize:15];
    }
    return _nickNameLabel;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.userInteractionEnabled = YES;
    }
    return _headImageView;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.tag = 100;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.userInteractionEnabled = YES;
    }
    return _bgImgView;
}

- (UIView *)effectView {
    if (!_effectView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        } else {
            UIToolbar *effectView = [[UIToolbar alloc] init];
            effectView.barStyle = UIBarStyleBlackTranslucent;
            _effectView = effectView;
        }
    }
    return _effectView;
}

@end
