//
//  MPUserDynamicViewController.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/18.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPUserDynamicViewController.h"
#import "MPUserDynamicCollectionViewCell.h"
#import "ZFUtilities.h"
#import "ZFTableData.h"
#import "MPUserDynamicDetailViewController.h"
#import <ZFPlayer/UIImageView+ZFCache.h>

@interface MPUserDynamicViewController ()<
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation MPUserDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestData];
    [self setup];
}

- (void)requestData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    self.dataSource = @[].mutableCopy;
    NSArray *videoList = [rootDict objectForKey:@"list"];
    for (NSDictionary *dataDic in videoList) {
        ZFTableData *data = [[ZFTableData alloc] init];
        [data setValuesForKeysWithDictionary:dataDic];
        [self.dataSource addObject:data];
    }
}

- (void)setup
{
    self.view.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(80, 80);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    [self.collectionView registerClass:[MPUserDynamicCollectionViewCell class] forCellWithReuseIdentifier:@"MPUserDynamicCollectionViewCell"];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    self.collectionView.frame = CGRectMake(0, 100, self.view.frame.size.width, 80);
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPUserDynamicCollectionViewCell *cell = (MPUserDynamicCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MPUserDynamicCollectionViewCell" forIndexPath:indexPath];
    ZFTableData *data = self.dataSource[indexPath.row];
    [cell.iconImageView setImageWithURLString:data.head placeholder:nil];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPUserDynamicDetailViewController *vc = [[MPUserDynamicDetailViewController alloc] init];
    vc.index = indexPath.row;
    vc.totalCount = self.dataSource.count;
    MPUserDynamicCollectionViewCell *cell = (MPUserDynamicCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    vc.iconImage = cell.iconImageView.image;
    vc.startImageView = cell.iconImageView;
    vc.startCell = cell;
    self.navigationController.delegate = vc;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
