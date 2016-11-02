//
//  ViewController.m
//  SYPhotoBrowserDemo
//
//  Created by 孙扬 on 2016/11/2.
//  Copyright © 2016年 孙扬. All rights reserved.
//

#import "ViewController.h"
#import <YYWebImage/YYWebImage.h>
#import "SYPhotoBrowser.h"
#import "CollectionCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic ,strong) UICollectionView *collectionView;

@property (nonatomic ,strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell * cell = [CollectionCell cellWithCollectionView:collectionView indexPath:indexPath];
    cell.imageString = self.dataSource[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
     CGFloat w = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake((w - 15) / 3, (w - 15) / 3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 5, 0);
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        layout.minimumLineSpacing          = 1;
        layout.minimumInteritemSpacing     = 0;
        _collectionView                    = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, w, w - 64)
                                                                collectionViewLayout:layout];
        _collectionView.delegate        = self;
        _collectionView.dataSource      = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"CollectionCell" bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:@"CollectionCell"];
    }
    return _collectionView;
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
