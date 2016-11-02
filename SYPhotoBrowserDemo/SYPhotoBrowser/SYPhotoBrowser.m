//
//  SYPhotoBrowser.m
//  DPHMechart
//
//  Created by 孙扬 on 2016/11/1.
//  Copyright © 2016年 MichealSun. All rights reserved.
//

#import "SYPhotoBrowser.h"
#import "SYPhotoView.h"
#import <YYWebImage/YYWebImage.h>


@interface SYPhotoBrowser()<UIScrollViewDelegate , SYPhotoViewDelegate>

/// 图片数组，3个 UIImageView。进行复用
@property (nonatomic, strong) NSMutableArray<SYPhotoView *> *pictureViews;
/// 准备待用的图片视图（缓存）
@property (nonatomic, strong) NSMutableArray<SYPhotoView *> *readyToUsePictureViews;
/// 图片张数
@property (nonatomic, assign) NSInteger picturesCount;
/// 当前页数
@property (nonatomic, assign) NSInteger currentPage;
/// 界面子控件
@property (nonatomic, weak) UIScrollView *scrollView;
/// 页码文字控件
@property (nonatomic, weak) UILabel *pageTextLabel;
/// 消失的 tap 手势
@property (nonatomic, weak) UITapGestureRecognizer *dismissTapGes;

@end

@implementation SYPhotoBrowser

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUserInterface];
    }
    return self;
}

- (void)setupUserInterface {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    // 设置默认属性
    self.betweenImageSapcing = 20;
    self.pageTextFont = [UIFont systemFontOfSize:16];
    self.pageTextCenter = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height - 20);
    self.pageTextColor = [UIColor whiteColor];
    // 初始化数组
    self.pictureViews = [NSMutableArray array];
    self.readyToUsePictureViews = [NSMutableArray array];
    
    // 初始化 scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(- _betweenImageSapcing * 0.5, 0, self.frame.size.width + _betweenImageSapcing, self.frame.size.height)];
    scrollView.showsVerticalScrollIndicator = false;
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.pagingEnabled = true;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 初始化label
    UILabel *label = [[UILabel alloc] init];
    label.alpha = 0;
    label.textColor = self.pageTextColor;
    label.center = self.pageTextCenter;
    label.font = self.pageTextFont;
    [self addSubview:label];
    self.pageTextLabel = label;
    
    // 添加手势事件
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longGes];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [self addGestureRecognizer:tapGes];
    self.dismissTapGes = tapGes;
}

- (void)showFromView:(UIView *)fromView
          photoCount:(NSInteger)photoCount
   currentPhotoIndex:(NSInteger)currentPhotoIndex {
    
    NSString *errorStr = [NSString stringWithFormat:@"Parameter is not correct, pictureCount is %zd, currentPictureIndex is %zd", photoCount, currentPhotoIndex];
    NSAssert(photoCount > 0 && currentPhotoIndex < photoCount, errorStr);
    NSAssert(self.dataSource != nil, @"Please set up delegate for pictureBrowser");
    
    // 记录值并设置位置
    self.picturesCount = photoCount;
    self.currentPage = currentPhotoIndex;
    [self setPageText:currentPhotoIndex];
    // 添加到 window 上
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 计算 scrollView 的 contentSize
    self.scrollView.contentSize = CGSizeMake(photoCount * _scrollView.frame.size.width, _scrollView.frame.size.height);
    // 滚动到指定位置
    [self.scrollView setContentOffset:CGPointMake(currentPhotoIndex * _scrollView.frame.size.width, 0) animated:false];
    // 设置第1个 view 的位置以及大小
    SYPhotoView *pictureView = [self setPictureViewForIndex:currentPhotoIndex];
    // 获取来源图片在屏幕上的位置
    CGRect rect = [fromView convertRect:fromView.bounds toView:nil];
    
    [pictureView animationShowWithFromRect:rect animationBlock:^{
        self.backgroundColor = [UIColor blackColor];
        self.pageTextLabel.alpha = 1;
    } completionBlock:^{
        // 设置左边与右边的 pictureView
        if (currentPhotoIndex != 0 && photoCount > 1) {
            // 设置左边
            [self setPictureViewForIndex:currentPhotoIndex - 1];
        }
        
        if (currentPhotoIndex < photoCount - 1) {
            // 设置右边
            [self setPictureViewForIndex:currentPhotoIndex + 1];
        }
    }];
}

- (void)dismiss {
    UIView *endView = [_dataSource photoView:self viewForIndex:_currentPage];
    CGRect rect = [endView convertRect:endView.bounds toView:nil];
    // 取到当前显示的 pictureView
    SYPhotoView *pictureView = [[_pictureViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index == %d", _currentPage]] firstObject];
    // 取消所有的下载
    for (SYPhotoView *pictureView in _pictureViews) {
        [pictureView.imageView yy_cancelCurrentImageRequest];
    }
    
    for (SYPhotoView *pictureView in _readyToUsePictureViews) {
        [pictureView.imageView yy_cancelCurrentImageRequest];
    }
    
    // 执行关闭动画
    [pictureView animationDismissWithToRect:rect animationBlock:^{
        self.backgroundColor = [UIColor clearColor];
        self.pageTextLabel.alpha = 0;
    } completionBlock:^{
        [self removeFromSuperview];
    }];
}

#pragma mark - 监听事件

- (void)tapGes:(UITapGestureRecognizer *)ges {
    [self dismiss];
}

- (void)longPress:(UILongPressGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        if (self.longPressBlock) {
            self.longPressBlock(_currentPage);
        }
    }
}

#pragma mark - 私有方法

- (void)setPageTextFont:(UIFont *)pageTextFont {
    _pageTextFont = pageTextFont;
    self.pageTextLabel.font = pageTextFont;
}

- (void)setPageTextColor:(UIColor *)pageTextColor {
    _pageTextColor = pageTextColor;
    self.pageTextLabel.textColor = pageTextColor;
}

- (void)setPageTextCenter:(CGPoint)pageTextCenter {
    _pageTextCenter = pageTextCenter;
    [self.pageTextLabel sizeToFit];
    self.pageTextLabel.center = pageTextCenter;
}

- (void)setBetweenImagesSpacing:(CGFloat)betweenImagesSpacing {
    _betweenImageSapcing = betweenImagesSpacing;
    self.scrollView.frame = CGRectMake(-_betweenImageSapcing * 0.5, 0, self.frame.size.width + _betweenImageSapcing, self.frame.size.height);
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage) {
        return;
    }
    NSUInteger oldValue = _currentPage;
    _currentPage = currentPage;
    [self removeViewToReUse];
    [self setPageText:currentPage];
    // 如果新值大于旧值
    if (currentPage > oldValue) {
        // 往右滑，设置右边的视图
        if (currentPage + 1 < _picturesCount) {
            [self setPictureViewForIndex:currentPage + 1];
        }
    }else {
        // 往左滑，设置左边的视图
        if (currentPage > 0) {
            [self setPictureViewForIndex:currentPage - 1];
        }
    }
    
}

/**
 设置pitureView到指定位置
 
 @param index 索引
 
 @return 当前设置的控件
 */
- (SYPhotoView *)setPictureViewForIndex:(NSInteger)index {
    [self removeViewToReUse];
    SYPhotoView *view = [self getPhotoView];
    view.index = index;
    CGRect frame = view.frame;
    frame.size = self.frame.size;
    view.frame = frame;
    
    // 设置图片的大小<在下载完毕之后会根据下载的图片计算大小>
    CGSize defaultSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    
    void(^setImageSizeBlock)(UIImage *) = ^(UIImage *image) {
        if (image != nil) {
            if (image != nil) {
                view.pictureSize = image.size;
            }else {
                view.pictureSize = defaultSize;
            }
        }
    };
    
    // 1. 判断是否实现图片大小的方法
    if ([_dataSource respondsToSelector:@selector(photoView:imageSizeForIndex:)]) {
        view.pictureSize = [_dataSource photoView:self imageSizeForIndex:index];
    }else if ([_dataSource respondsToSelector:@selector(photoView:defaultImageForIndex:)]) {
        UIImage *image = [_dataSource photoView:self defaultImageForIndex:index];
        // 2. 如果没有实现，判断是否有默认图片，获取默认图片大小
        setImageSizeBlock(image);
    } else if ([_dataSource respondsToSelector:@selector(photoView:viewForIndex:)]) {
        UIView *v = [_dataSource photoView:self viewForIndex:index];
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImage *image = ((UIImageView *)v).image;
            setImageSizeBlock(image);
            // 并且设置占位图片
            view.placeholderImage = image;
        }
    }else {
        // 3. 如果都没有就设置为屏幕宽度，待下载完成之后再次计算
        view.pictureSize = defaultSize;
    }
    
    // 设置占位图
    if ([_dataSource respondsToSelector:@selector(photoView:defaultImageForIndex:)]) {
        view.placeholderImage = [_dataSource photoView:self defaultImageForIndex:index];
    }
    
    view.urlString = [_dataSource photoView:self highQualityUrlStringForIndex:index];
    
    CGPoint center = view.center;
    center.x = index * _scrollView.frame.size.width + _scrollView.frame.size.width * 0.5;
    view.center = center;
    return view;
}


/**
 获取图片控件：如果缓存里面有，那就从缓存里面取，没有就创建
 
 @return 图片控件
 */
- (SYPhotoView *)getPhotoView {
    SYPhotoView *view;
    if (_readyToUsePictureViews.count == 0) {
        view = [SYPhotoView new];
        // 手势事件冲突处理
        [self.dismissTapGes requireGestureRecognizerToFail:view.imageView.gestureRecognizers.firstObject];
        view.photoDelegate = self;
    }else {
        view = [_readyToUsePictureViews firstObject];
        [_readyToUsePictureViews removeObjectAtIndex:0];
    }
    [_scrollView addSubview:view];
    [_pictureViews addObject:view];
    return view;
}

/**
 移动到超出屏幕的视图到可重用数组里面去
 */
- (void)removeViewToReUse {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (SYPhotoView *view in self.pictureViews) {
        // 判断某个view的页数与当前页数相差值为2的话，那么让这个view从视图上移除
        if (abs((int)view.index - (int)_currentPage) == 2){
            [tempArray addObject:view];
            [view removeFromSuperview];
            [_readyToUsePictureViews addObject:view];
        }
    }
    [self.pictureViews removeObjectsInArray:tempArray];
}

/**
 设置文字，并设置位置
 */
- (void)setPageText:(NSUInteger)index {
    _pageTextLabel.text = [NSString stringWithFormat:@"%zd / %zd", index + 1, self.picturesCount];
    [_pageTextLabel sizeToFit];
    _pageTextLabel.center = self.pageTextCenter;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger page = (scrollView.contentOffset.x / scrollView.frame.size.width + 0.5);
    self.currentPage = page;
}

#pragma mark - ESPictureViewDelegate

- (void)photoViewTouch:(SYPhotoView *)photoView {
    [self dismiss];
}

- (void)photoView:(SYPhotoView *)photoView scale:(CGFloat)scale {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - scale];
}

@end
