//
//  HFAlbumListViewController.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/1/11.
//  Copyright © 2019年 jackson. All rights reserved.
//

#import "HFAlbumListViewController.h"
#import "FHTableViewDataSource.h"

/**
    展示两组，一组为系统智能相册，一组为个人创建相册
 */
///相册功能
@interface HFAlbumListViewController ()<UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *albumListArr;

@property (nonatomic, strong) UITableView *albumTableView;

//@property (nonatomic, strong) FHTableViewDataSource *dataSource;

@end

@implementation HFAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self _configSubView];
}

#pragma mark- private method
- (void)_configSubView
{
    [self.view addSubview:self.albumTableView];
}

#pragma mark- setter/getter
- (UITableView *)albumTableView
{
    if(!_albumTableView){
        _albumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _albumTableView.delegate = self;
    }
    return _albumTableView;
}

//- (FHTableViewDataSource *)dataSource
//{
//    if(!_dataSource){
//        _dataSource = [FHTableViewDataSource datasourceWithCellIdentifier:@"FHAlbumCell" mulitSection:YES configureCellBlock:^(UITableViewCell *cell, id item) {
//
//        }];
//    }
//    return _dataSource;
//}




@end
