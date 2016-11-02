//
//  SYPhotoBrowser.h
//  DPHMechart
//
//  Created by 孙扬 on 2016/11/1.
//  Copyright © 2016年 MichealSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYPhotoBrowser;

@protocol SYPhotoBrowserDataSource <NSObject>

@required

/**
 获取对应的索引

 @param photeBrowser 图片浏览器
 @param index 索引
 @return 试图
 */
- (UIView *)photoView:(SYPhotoBrowser *)photeBrowser viewForIndex:(NSInteger)index;

@optional

/**
 获取对一个索引的图片的大小

 @param photeBrowser 图片浏览器
 @param index 索引
 @return 图片大小
 */
- (CGSize)photoView:(SYPhotoBrowser *)photeBrowser imageSizeForIndex:(NSInteger)index;

#pragma mark -  以下两个代理方法必须实现一个
/**
 获取对应索引默认图片，可以是占位图片，可以是缩略图

 @param photoBrowser 图片浏览器
 @param index 索引
 @return 图片
 */
- (UIImage *)photoView:(SYPhotoBrowser *)photoBrowser defaultImageForIndex:(NSInteger)index;

/**
 获取对应索引的高质量图片地址字符串

 @param photoBrowser 图片浏览器
 @param index 索引
 @return 图片的 URL 字符串
 */
- (NSString *)photoView:(SYPhotoBrowser *)photoBrowser highQualityUrlStringForIndex:(NSInteger)index;


/**
 图片向上拉动时执行的动作

 @param photoBrowser 图片浏览器
 @param index 图片的索引
 */
- (void)photoViewDragUp:(SYPhotoBrowser *)photoBrowser viewForIndex:(NSInteger)index NS_UNAVAILABLE;

@end

@interface SYPhotoBrowser : UIView

/**
 代理
 */
@property (nonatomic ,weak) id <SYPhotoBrowserDataSource>dataSource;

/**
 图片之间的间距， 默认： 20
 */
@property (nonatomic ,assign) CGFloat betweenImageSapcing;

/**
 页数文字中心店， 默认： 居中， 中心 y 距离底部 20
 */
@property (nonatomic ,assign) CGPoint pageTextCenter;

/**
 页数文字字体， 默认：系统字体， 16号
 */
@property (nonatomic ,strong) UIFont *pageTextFont;

/**
 页数文字颜色， 默认： 白色
 */
@property (nonatomic ,strong) UIColor *pageTextColor;

/**
 长按图片要执行的时间，将长按图片索引回调
 */
@property (nonatomic ,copy) void(^longPressBlock)(NSInteger);


/**
 图片浏览器

 @param formView 用户点击的视图
 @param photoCount 图片的张数
 @param currentPhotoIndex 当前用户点击的图片索引
 */
- (void)showFromView:(UIView *)formView
          photoCount:(NSInteger)photoCount
   currentPhotoIndex:(NSInteger)currentPhotoIndex;

/**
 让浏览器消失
 */
- (void)dismiss;
@end
