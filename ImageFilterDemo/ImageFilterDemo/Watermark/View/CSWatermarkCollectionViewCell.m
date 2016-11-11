//
//  CSWatermarkCollectionViewCell.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/11/11.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSWatermarkCollectionViewCell.h"

@implementation CSWatermarkCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self reset];
}

- (void)reset
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)setWatermarkType:(CSWatermarkType)watermarkType
{
    [self reset];
    
    _watermarkType = watermarkType;
    
    switch (_watermarkType) {
        case CSWatermarkType_None:
            [self watermarkNone];
            break;
        case CSWatermarkType_1:
            [self watermark1];
            break;
        case CSWatermarkType_2:
            [self watermark2];
            break;
        default:
            break;
    }
}

#pragma mark - watermark

- (void)watermarkNone
{
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:label];
    
    label.text = @"水印0";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:30.f];
}

- (void)watermark1
{
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:label];
    
    label.text = @"水印1";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:30.f];
}

- (void)watermark2
{
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:label];
    
    label.text = @"水印2";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:30.f];
}

@end
