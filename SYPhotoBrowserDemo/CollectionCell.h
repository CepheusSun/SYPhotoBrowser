//
//  CollectionCell.h
//  SYPhotoBrowserDemo
//
//  Created by 孙扬 on 2016/11/2.
//  Copyright © 2016年 孙扬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionCell : UICollectionViewCell

@property (nonatomic,copy) NSString * imageString;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
