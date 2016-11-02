//
//  TableViewController.m
//  SYPhotoBrowserDemo
//
//  Created by 孙扬 on 2016/11/2.
//  Copyright © 2016年 孙扬. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"

@interface TableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) NSMutableArray *dataSource;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [TableViewCell cellWithTableView:tableView];
    cell.imageUrls = self.dataSource;
    return cell;
}


- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[
                        @"http://ocg4av0wv.bkt.clouddn.com/u=2092036709,1309596713&fm=21&gp=0.gif",
                        @"http://ocg4av0wv.bkt.clouddn.com/u=2396531920,660144558&fm=21&gp=0.gif",
                        @"http://ocg4av0wv.bkt.clouddn.com/u=3378537055,1780455462&fm=21&gp=0.gif",
                        ].mutableCopy;
    }
    return _dataSource;
}
@end
