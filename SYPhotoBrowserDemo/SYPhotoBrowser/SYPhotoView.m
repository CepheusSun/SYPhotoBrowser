//
//  SYPhotoView.m
//  DPHMechart
//
//  Created by 孙扬 on 2016/11/1.
//  Copyright © 2016年 MichealSun. All rights reserved.
//

#import "SYPhotoView.h"
#import "SYPhotoProgressView.h"
#import <YYWebImage/YYWebImage.h>

@interface SYPhotoView() <UIScrollViewDelegate>

@property (nonatomic ,assign) CGSize showPictureSize;

@property (nonatomic ,assign) BOOL doubleClicks;

@property (nonatomic ,assign) CGPoint lastContentOffset;

@property (nonatomic ,assign) CGFloat scale;

@property (nonatomic ,assign) CGFloat offsetY;

@property (nonatomic ,weak) SYPhotoProgressView *progressView;

@property (nonatomic ,assign ,getter=isShowAnimation) BOOL showAnimation;

@end


@implementation SYPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUserInterface];
    }
    return self;
}

- (void)setupUserInterface {
    self.delegate = self;
    self.alwaysBounceVertical = YES;
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.maximumZoomScale = 2;
    
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode =  UIViewContentModeScaleToFill /*UIViewContentModeScaleAspectFill*/  ;
    imageView.frame = self.bounds;
    imageView.userInteractionEnabled = YES;
    _imageView = imageView;
    [self addSubview:imageView];
    
    SYPhotoProgressView *progressView = [[SYPhotoProgressView alloc] init];
    [self addSubview:progressView];
    self.progressView = progressView;
    
    UITapGestureRecognizer *doubleTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTapped.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTapped];
}

#pragma mark - 外部方法

- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void (^)())animationBlock completionBlock:(void (^)())completionBlock {
    _imageView.frame = rect;
    self.showAnimation = YES;
    [self.progressView setHidden:YES];
    [UIView animateWithDuration:0.25 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        self.imageView.frame = [self getImageActualFrame:self.showPictureSize];
    }completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
        self.showAnimation = NO;
    }];
}

- (void)animationDismissWithToRect:(CGRect)rect animationBlock:(void (^)())animationBlock completionBlock:(void (^)())completionBlock {
    
    self.progressView.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        CGRect toRect = rect;
        toRect.origin.y += self.offsetY;
        toRect.origin.x += self.contentOffset.x;
        self.imageView.frame = toRect;
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

#pragma mark - 私有方法
- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
}

- (void)setShowAnimation:(BOOL)showAnimation {
    _showAnimation = showAnimation;
    if (showAnimation) {
        self.progressView.hidden = YES;
    }else {
        self.progressView.hidden = self.progressView.progress == 1;
    }
}

- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    [self.imageView yy_cancelCurrentImageRequest];
    self.progressView.progress = 0.01;
    if (!self.isShowAnimation) {
        self.progressView.hidden = NO;
    }
    self.userInteractionEnabled = NO;
    
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:urlString] placeholder:self.placeholderImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = (CGFloat)receivedSize / expectedSize;
        self.progressView.progress = progress;
    } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (error) {
            [self.progressView showError];
        }else {
            if (stage == YYWebImageStageFinished) {
                self.progressView.hidden = YES;
                self.userInteractionEnabled = YES;
                if (image) {
                    [self setPictureSize:image.size];
                }else {
                    [self.progressView showError];
                }
                self.progressView.progress = 1;
            }
        }
    }];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.25 animations:^{
            CGPoint center = self.imageView.center;
            center.x = self.contentSize.width * 0.5;
            self.imageView.center = center;
        }];
    }
}

- (void)setPictureSize:(CGSize)pictureSize {
    _pictureSize = pictureSize;
    if (CGSizeEqualToSize(pictureSize, CGSizeZero)) {
        return;
    }
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = screenW / pictureSize.width;
    CGFloat height = scale * pictureSize.height;
    self.showPictureSize = CGSizeMake(screenW, height);
}

- (void)setShowPictureSize:(CGSize)showPictureSize {
    _showPictureSize = showPictureSize;
    self.imageView.frame = [self getImageActualFrame:_showPictureSize];
    self.contentSize = self.imageView.frame.size;
}

- (CGRect)getImageActualFrame:(CGSize)imageSize {
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (imageSize.height < [UIScreen mainScreen].bounds.size.height) {
        y = ([UIScreen mainScreen].bounds.size.height - imageSize.height) / 2;
    }
    return CGRectMake(x, y, imageSize.width, imageSize.height);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height / scale;
    zoomRect.size.width  =self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - 监听方法
- (void)doubleClick:(UITapGestureRecognizer *)ges {
    CGFloat newScale = 2;
    if (_doubleClicks) {
        newScale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[ges locationInView:ges.view]];
    [self zoomToRect:zoomRect animated:YES];
    _doubleClicks = !_doubleClicks;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
    _offsetY = scrollView.contentOffset.y;
    if ([self.imageView.layer animationForKey:@"transform"] != nil) {
        return;
    }
    if (self.zoomBouncing || self.zooming) {
        return;
    }
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (scrollView.contentSize.height > screenH) {
        if (_lastContentOffset.y > 0 && _lastContentOffset.y <= scrollView.contentSize.height - screenH) {
            return;
        }
    }
    _scale = fabs(_lastContentOffset.y) / screenH;
    
    if (scrollView.contentSize.height > screenH &&
        _lastContentOffset.y > scrollView.contentSize.height - screenH) {
        _scale = (_lastContentOffset.y - (scrollView.contentSize.height - screenH)) / screenH;
    }
    if (scrollView.contentSize.height > screenH) {
        if (scrollView.contentOffset.y < 0 || _lastContentOffset.y > scrollView.contentSize.height - screenH) {
            [_photoDelegate photoView:self scale:_scale];
        }
    }else {
        [_photoDelegate photoView:self scale:_scale];
    }
    
    if (scrollView.dragging == false) {
        if (_scale > 0.15 && _scale <= 1) {
            // 关闭
            [_photoDelegate photoViewTouch:self];
            // 设置 contentOffset
            [scrollView setContentOffset:_lastContentOffset animated:false];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGPoint center = _imageView.center;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    center.y = scrollView.contentSize.height * 0.5 + offsetY;
    _imageView.center = center;
    
    // 如果是缩小，保证在屏幕中间
    if (scrollView.zoomScale < scrollView.minimumZoomScale) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        center.x = scrollView.contentSize.width * 0.5 + offsetX;
        _imageView.center = center;
    }
}

@end
