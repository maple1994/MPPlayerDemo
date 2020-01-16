//
//  MPWaterFallViewController.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/1/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPWaterFallViewController.h"
#import "MPWaterFallCollectionViewCell.h"
#import "MPWaterFallLayout.h"
#import "ZFUtilities.h"
#import "ZFTableData.h"
#import "MPDetailViewController.h"

@interface MPWaterFallViewController ()<MPWaterFallLayoutDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MPWaterFallLayout *layout;

@end

@implementation MPWaterFallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    MPWaterFallLayout *layout = [MPWaterFallLayout waterFallLayoutWithColumn:2];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 0);
    layout.columnSpacing = 10;
    layout.rowSpacing = 10;
    layout.dataSource = self;
    self.layout = layout;
    
    CGFloat y = iPhoneX ? 88 : 64;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, ZFPlayer_ScreenWidth, ZFPlayer_ScreenHeight - y) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[MPWaterFallCollectionViewCell class] forCellWithReuseIdentifier:@"MPWaterFallCollectionViewCellID"];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.collectionView];
    [self requestData];
    [self.collectionView reloadData];
}

- (void)requestData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    self.dataSource = @[].mutableCopy;
    NSArray *videoList = [rootDict objectForKey:@"list"];
    for (NSDictionary *dataDic in videoList) {
        ZFTableData *data = [[ZFTableData alloc] init];
        [data setValuesForKeysWithDictionary:dataDic];
        data.thumbnail_height = (self.layout.itemWidth / data.thumbnail_width) * data.thumbnail_height;
        [self.dataSource addObject:data];
    }
}


// MARK: - MPWaterFallLayoutDataSource
- (CGFloat)waterFallLayout:(MPWaterFallLayout *)layout itemHeightForItemWidth:(CGFloat)itemWidth atIndexPath:(NSIndexPath *)indexPath
{
    ZFTableData *data = self.dataSource[indexPath.row];
    return data.thumbnail_height;
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPWaterFallCollectionViewCell *cell = (MPWaterFallCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MPWaterFallCollectionViewCellID" forIndexPath:indexPath];
    ZFTableData *data = self.dataSource[indexPath.row];
    cell.data = data;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPWaterFallCollectionViewCell *cell = (MPWaterFallCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    MPDetailViewController *vc = [[MPDetailViewController alloc] init];
    vc.index = indexPath.row;
    vc.startImage = cell.imageView.image;
    vc.startView = cell.imageView;
    vc.dataSource = [self.dataSource mutableCopy];
    self.navigationController.delegate = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
