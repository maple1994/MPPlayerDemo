//
//  MPCardLayoutViewController.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/16.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPCardLayoutViewController.h"
#import "ZFUtilities.h"
#import "ZFTableData.h"
#import "MPCardStackLayout.h"
#import "MPCardLayoutCell.h"
#import <ZFPlayer/UIImageView+ZFCache.h>

@interface MPCardLayoutViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation MPCardLayoutViewController

- (void)viewDidLoad
{
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
    MPCardStackLayout *layout = [[MPCardStackLayout alloc] init];
    CGFloat itemW = self.view.bounds.size.width - 16 - 20 * 2 - 15;
    CGFloat itemH = itemW + 97;
    layout.itemSize = CGSizeMake(itemW, itemH);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    [self.collectionView registerClass:[MPCardLayoutCell class] forCellWithReuseIdentifier:@"MPCardLayoutCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    self.collectionView.frame = CGRectMake(0, 100, self.view.bounds.size.width, itemH);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPCardLayoutCell *cell = (MPCardLayoutCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MPCardLayoutCell" forIndexPath:indexPath];
    ZFTableData *data = self.dataSource[indexPath.row];
    [cell.coverImageView setImageWithURLString:data.thumbnail_url placeholderImageName:nil];
    return cell;
}

@end
