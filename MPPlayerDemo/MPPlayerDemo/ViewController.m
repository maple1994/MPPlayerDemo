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
#import "MPCardLayoutViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *controllerArr;
@property (nonatomic, copy) NSArray *demoName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.controllerArr = @[
        @"MPListViewController",
        @"MPDetailViewController",
        @"MPWaterFallViewController",
        @"MPCardLayoutViewController"
    ];
    self.demoName = @[
        @"预加载-列表播放-无缝续播",
        @"预加载-抖音列表",
        @"瀑布流列表-转场动画演示",
        @"卡片布局演示"
    ];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
}

// MARK: - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.demoName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.demoName[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class cl = NSClassFromString(self.controllerArr[indexPath.row]);
    UIViewController *vc = [[cl alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
