//
//  PhotoViewController.m
//  demo
//
//  Created by ChunmengYang on 2019/7/16.
//  Copyright © 2019 ChunmengYang. All rights reserved.
//
#import "PhotoViewController.h"

@interface PhotoViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *preImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.picView.userInteractionEnabled = YES;
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
    
    [self.picView addGestureRecognizer:tap];
    
}

-(void)showZoomImageView:(UITapGestureRecognizer *)tap
{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    //scrollView作为背景
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = [UIScreen mainScreen].bounds;
    scrollView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    [scrollView addGestureRecognizer:tapBg];
    
    UIImageView *picView = (UIImageView *)tap.view;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = picView.image;
    
    imageView.frame = [scrollView convertRect:picView.frame fromView:self.view];
    
    //渐入式
//    CGRect frame = imageView.frame;
//    frame.size.width = scrollView.frame.size.width;
//    frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
//    frame.origin.x = 0;
//    frame.origin.y = (scrollView.frame.size.height - frame.size.height) * 0.5;
//    imageView.frame = frame;
//    scrollView.alpha = 0;
    
    [scrollView addSubview:imageView];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    indicatorView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                            scrollView.contentSize.height * 0.5 + offsetY);
    
    CGAffineTransform transform = CGAffineTransformMakeScale(2, 2);
    indicatorView.transform = transform;
    
    [scrollView addSubview:indicatorView];
    [indicatorView startAnimating];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:scrollView];
    
    self.preImageView = imageView;
    self.originalFrame = imageView.frame;
    self.scrollView = scrollView;
    self.scrollView.delegate = self;
    //最大放大比例
    self.scrollView.maximumZoomScale = 3;
    //垂直滚动条
    self.scrollView.showsVerticalScrollIndicator = FALSE;
    //水平滚动条
    self.scrollView.showsHorizontalScrollIndicator = FALSE;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = scrollView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;

        CGFloat imageY = (scrollView.frame.size.height - frame.size.height) * 0.5;
        if (imageY <= 0) {
            imageY = 0;
        }
        frame.origin.y = imageY;
        imageView.frame = frame;
        
        //渐入式
//        scrollView.alpha = 1;
    } completion:^(BOOL finished) {
        [indicatorView removeFromSuperview];
    }];
}

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer
{
    self.scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.5 animations:^{
        self.preImageView.frame = self.originalFrame;
        tapBgRecognizer.view.backgroundColor = [UIColor clearColor];
        
        //渐入式
//        tapBgRecognizer.view.alpha = 0;
    } completion:^(BOOL finished) {
        [tapBgRecognizer.view removeFromSuperview];
        self.scrollView = nil;
        self.preImageView = nil;
    }];
}

//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.preImageView;
}

//让图片居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.preImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
