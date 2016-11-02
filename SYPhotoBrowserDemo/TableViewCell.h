//
//  TableViewCell.h
//  SYPhotoBrowserDemo
//
//  Created by 孙扬 on 2016/11/2.
//  Copyright © 2016年 孙扬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell


@property (nonatomic ,strong) NSMutableArray *imageUrls;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


@end
