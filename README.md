# SYPhotoBrowser

图片浏览器，使用方法类似UITableView的图片浏览器。基于YYWebImage



### GIF

<img src="http://ocg4av0wv.bkt.clouddn.com/SYPhotoBrowser.gif" width=500/>



### Usage

#### 初始化

```objective-c
 SYPhotoBrowser *browser = [[SYPhotoBrowser alloc] init];
    [browser setDataSource:self];
    NSInteger idx = 0;
    [browser showFromView:ges.view photoCount:self.imageUrls.count currentPhotoIndex:idx];

```



#### Datasource

```objective-c
- (UIView *)photoView:(SYPhotoBrowser *)photeBrowser viewForIndex:(NSInteger)index;
- (CGSize)photoView:(SYPhotoBrowser *)photeBrowser imageSizeForIndex:(NSInteger)index;
- (UIImage *)photoView:(SYPhotoBrowser *)photoBrowser defaultImageForIndex:(NSInteger)index;
- (NSString *)photoView:(SYPhotoBrowser *)photoBrowser highQualityUrlStringForIndex:(NSInteger)index;

```

