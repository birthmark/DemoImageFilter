//
//  ViewImageCrop.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/10/14.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "ViewImageCrop.h"
#import "UIImage+CSCategory.h"

@implementation ViewImageCrop
{
    UIImageView *_imageViewAlbumCoverCrop;
    UIView *_maskView;
    
    CGFloat scaleImage;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    _imageViewAlbumCoverCrop.image = _image;
}

- (void)initSubviews
{
    _imageViewAlbumCoverCrop = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageViewAlbumCoverCrop.contentMode = UIViewContentModeScaleAspectFit;
    scaleImage = _image.size.height / _imageViewAlbumCoverCrop.frame.size.height;
    [self addSubview:_imageViewAlbumCoverCrop];
    
    CGFloat widthMaskView = CGRectGetHeight(self.frame) / 16 * 9;
    CGRect frameMaskView = CGRectMake((CGRectGetWidth(self.frame) - widthMaskView) / 2, 0, widthMaskView, CGRectGetHeight(self.frame));
    _maskView = [[UIView alloc] initWithFrame:frameMaskView];
    [self addSubview:_maskView];
    _maskView.backgroundColor = [UIColor redColor];
    _maskView.alpha = 0.5f;
}

- (CGRect)realClipRect
{
    CGRect cropRect = self.frame;
    cropRect = CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.height);
    
    //UIImageView *imageBG = (UIImageView*)[self.superview viewWithTag:33];
    //放缩比例
    //float zoomX = self.view.frame.size.width / imageBG.image.size.width;
    //float zoomY = self.view.frame.size.height / imageBG.image.size.height;
    float zoomX = _imageViewAlbumCoverCrop.image.size.width / _maskView.frame.size.width;
    float zoomY = _imageViewAlbumCoverCrop.image.size.height / _maskView.frame.size.height;
    
    CGRect realRc = CGRectMake((cropRect.origin.x - _maskView.frame.origin.x) * zoomX ,
                               (cropRect.origin.y - _maskView.frame.origin.y) * zoomY ,
                               cropRect.size.width * zoomX,
                               cropRect.size.height * zoomY);
    return realRc;
    
}

- (UIImage *)imageCropped
{
    CGRect rect = [self realClipRect];
    UIImage *ret = [_image croppedImage:rect];
    return ret;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    _maskView.center = CGPointMake(touchPoint.x, _maskView.center.y);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    _maskView.center = CGPointMake(touchPoint.x, _maskView.center.y);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

@end
