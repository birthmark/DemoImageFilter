//
//  CSPreviewCollectionViewCell.m
//  ImageFilterDemo
//
//  Created by zj－db0465 on 16/11/8.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSPreviewCollectionViewCell.h"

@interface CSPreviewCollectionViewCell ()
<
    UIScrollViewDelegate
>

@end

@implementation CSPreviewCollectionViewCell
{
    UITapGestureRecognizer *_tapGesture;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initScrollView];
        [self initTapGesture];
    }
    return self;
}

- (void)initScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.f;
    _scrollView.maximumZoomScale = 4.f;
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
}

- (void)initTapGesture
{
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    _tapGesture.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:_tapGesture];
}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:_scrollView];
    
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    } else {
        CGRect rect = [self zoomRectWillPoint:touchPoint
                                      toScale:_scrollView.maximumZoomScale];
        [_scrollView zoomToRect:rect animated:YES];
//        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
}

/**
 *	@brief  获取定点放大的区域
 *
 *	@param point 坐标
 *	@param tScale 放大的倍数
 *
 *	@return 放大区域
 */
- (CGRect)zoomRectWillPoint:(CGPoint)point
                    toScale:(CGFloat)tScale {
    
    CGFloat width  =  CGRectGetWidth(self.bounds) / tScale;
    CGFloat height =  CGRectGetHeight(self.bounds) / tScale;
    CGFloat ox = point.x - width / 2.f;
    CGFloat oy = point.y - height / 2.f;
    
    // 计算偏移量
    CGSize showSize;
    showSize.width = MIN(CGRectGetWidth(self.bounds), CGRectGetWidth(_scrollView.frame));
    showSize.height = MIN(CGRectGetHeight(self.bounds), CGRectGetHeight(_scrollView.frame));
    
    CGFloat scale = showSize.width / showSize.height;
    
    if (width / height > scale) {
        width = height * scale;
    } else {
        height = width / scale;
    }
    
    return CGRectMake(ox, oy, width, height);
}

#pragma mark - <UIScrollViewDelegate>

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // imageView
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
