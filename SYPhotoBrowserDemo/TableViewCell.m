//
//  TableViewCell.m
//  SYPhotoBrowserDemo
//
//  Created by 孙扬 on 2016/11/2.
//  Copyright © 2016年 孙扬. All rights reserved.
//

#import "TableViewCell.h"
#import <YYWebImage/YYWebImage.h>
#import "SYPhotoBrowser.h"

@interface TableViewCell ()<SYPhotoBrowserDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImage;

@end
@implementation TableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *indentifier = @"TableViewCell";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setImageUrls:(NSMutableArray *)imageUrls {
    _imageUrls = imageUrls;
    _firstImage.yy_imageURL = [NSURL URLWithString:imageUrls[0]];
    _secondImage.yy_imageURL = [NSURL URLWithString:imageUrls[1]];
    _thirdImage.yy_imageURL = [NSURL URLWithString:imageUrls[2]];
    
    UITapGestureRecognizer *ges1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestTarget:)];
    [_firstImage addGestureRecognizer:ges1];
}

- (UIView *)photoView:(SYPhotoBrowser *)photeBrowser viewForIndex:(NSInteger)index {
    if (index == 0) {
        return _firstImage;
    };
    if (index == 1) {
        return _secondImage;
    }
    return _thirdImage;
}

- (UIImage *)photoView:(SYPhotoBrowser *)photoBrowser defaultImageForIndex:(NSInteger)index {
    if (index == 0) {
        return _firstImage.image;
    };
    if (index == 1) {
        return _secondImage.image;
    }
    return _thirdImage.image;
}

- (NSString *)photoView:(SYPhotoBrowser *)photoBrowser highQualityUrlStringForIndex:(NSInteger)index {
    return self.imageUrls[index];
}

- (void)gestTarget:(UIGestureRecognizer *)ges {
    SYPhotoBrowser *browser = [[SYPhotoBrowser alloc] init];
    [browser setDataSource:self];
    NSInteger idx = 0;
    [browser showFromView:ges.view photoCount:self.imageUrls.count currentPhotoIndex:idx];
}

@end
