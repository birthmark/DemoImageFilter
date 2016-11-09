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
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    } else {
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
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
