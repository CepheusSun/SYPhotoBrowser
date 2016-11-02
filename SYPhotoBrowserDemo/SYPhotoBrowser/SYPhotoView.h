//
//  SYPhotoView.h
//  DPHMechart
//
//  Created by 孙扬 on 2016/11/1.
//  Copyright © 2016年 MichealSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYPhotoView;
@protocol SYPhotoViewDelegate <NSObject>

- (void)photoViewTouch:(SYPhotoView *)photoView;

- (void)photoView:(SYPhotoView *)photoView scale:(CGFloat)scale;

@end

@interface SYPhotoView : UIScrollView

/**
 当前试图所在索引
 */
@property (nonatomic ,assign) NSInteger index;

/**
 图片大小
 */
@property (nonatomic ,assign) CGSize pictureSize;

/**
 显示的默认图片
 */
@property (nonatomic ,strong) UIImage *placeholderImage;

/**
 图片的地址URL
 */
@property (nonatomic ,copy) NSString *urlString;

/**
 当前显示图片的控件
 */
@property (nonatomic ,strong ,readonly) UIImageView *imageView;

/**
 代理
 */
@property (nonatomic ,weak) id<SYPhotoViewDelegate> photoDelegate;

/**
 动画显示

 @param rect 从那个位置开始动画
 @param animationBlock 附带的动画信息
 @param completionBlock 结束的回调
 */
- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void(^)())animationBlock
                  completionBlock:(void(^)())completionBlock;


/**
 动画消失

 @param rect 回到哪个位置
 @param animationBlock 附带的动画信息
 @param completionBlock 结束的回调
 */
- (void)animationDismissWithToRect:(CGRect)rect animationBlock:(void(^)())animationBlock
                   completionBlock:(void(^)())completionBlock;





@end
