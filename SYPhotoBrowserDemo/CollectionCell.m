//
//  CollectionCell.m
//  SYPhotoBrowserDemo
//
//  Created by 孙扬 on 2016/11/2.
//  Copyright © 2016年 孙扬. All rights reserved.
//

#import "CollectionCell.h"
#import <YYWebImage/YYWebImage.h>
#import "SYPhotoBrowser.h"

@interface CollectionCell ()<SYPhotoBrowserDataSource>

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *cellImageView;

@property (nonatomic ,assign)NSInteger idx;

@property (nonatomic ,strong)NSMutableArray *imageArray;
@end

@implementation CollectionCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    static NSString *indentifier = @"CollectionCell";
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CollectionCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setImageString:(NSString *)imageString {
    self.cellImageView.yy_imageURL = [NSURL URLWithString:imageString];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SYPhotoBrowser *browser = [[SYPhotoBrowser alloc] init];
    [browser setDataSource:self];
    [browser setLongPressBlock:^(NSInteger index) {
        
    }];
    [browser showFromView:self.cellImageView photoCount:self.imageArray.count currentPhotoIndex:0];
}

#pragma mark - SYPhotoBrowserDelegate

- (UIView *)photoView:(SYPhotoBrowser *)photeBrowser viewForIndex:(NSInteger)index {
    return self.cellImageView;
}

- (UIImage *)photoView:(SYPhotoBrowser *)photoBrowser defaultImageForIndex:(NSInteger)index {
    return  self.cellImageView.image;
}

- (NSString *)photoView:(SYPhotoBrowser *)photoBrowser highQualityUrlStringForIndex:(NSInteger)index {
    return self.imageArray[index];
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = @[
                        @"http://ocg4av0wv.bkt.clouddn.com/u=2092036709,1309596713&fm=21&gp=0.gif",
                        @"http://ocg4av0wv.bkt.clouddn.com/u=2396531920,660144558&fm=21&gp=0.gif",
                        @"http://ocg4av0wv.bkt.clouddn.com/u=3378537055,1780455462&fm=21&gp=0.gif",
                        ].mutableCopy;
    }
    return _imageArray;
}
@end
