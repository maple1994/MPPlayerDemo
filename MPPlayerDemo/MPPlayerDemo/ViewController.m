//
//  ViewController.m
//  MPPlayerDemo
//
//  Created by Maple on 2019/12/27.
//  Copyright © 2019 Maple. All rights reserved.
//

#import "ViewController.h"
#import "MPListViewController.h"
#import "MPDetailViewController.h"
#import "MPWaterFallViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
}

// MARK: - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"预加载-列表播放-无缝续播";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"预加载-抖音列表";
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"瀑布流列表-转场动画演示";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MPListViewController *vc = [[MPListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        MPDetailViewController *detailVC = [[MPDetailViewController alloc] init];
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if (indexPath.row == 2) {
        MPWaterFallViewController *vc = [[MPWaterFallViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
