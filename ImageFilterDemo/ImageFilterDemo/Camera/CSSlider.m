//
//  CSSlider.m
//  CustomUISlider
//
//  Created by Chris Hu on 16/8/31.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSSlider.h"

/**
 *  颜色宏定义
 */
#define RGB(r,g,b)        [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:1.f]
#define RGBA(r,g,b,a)     [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:a]
#define RGBHEX(hex)       RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),1.f)
#define RGBAHEX(hex,a)    RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),a)

static CGFloat heightLine = 1.5f; // slider的中间线height

@interface CSSlider ()

@end

@implementation CSSlider {
    
    UIView *bgView;     // 最底层的左橘色和右灰色
    UIView *trackView;  // 次底层的左灰色和右橘色，滑动时修改trackView的frame即可。
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commitInit];
        [self addTargetEvents];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
        [self addTargetEvents];
    }
    return self;
}

- (void)commitInit {
    self.minimumValue = 0.0f;
    self.maximumValue = 1.0f;
    self.middleVaule = (self.maximumValue - self.minimumValue) / 2;
    
    self.csMinimumTrackTintColor = RGBHEX(0xFF813C);
    self.csMaximumTrackTintColor = RGBHEX(0xDBDBDB);
}

- (void)setCsThumbImage:(UIImage *)csThumbImage {
    [self setThumbImage:csThumbImage forState:UIControlStateNormal];
}

- (void)setCsMinimumTrackTintColor:(UIColor *)csMinimumTrackTintColor {
    self.minimumTrackTintColor = [UIColor clearColor];
    
    _csMinimumTrackTintColor = csMinimumTrackTintColor;
}

- (void)setCsMaximumTrackTintColor:(UIColor *)csMaximumTrackTintColor {
    self.maximumTrackTintColor = [UIColor clearColor];
    
    _csMaximumTrackTintColor = csMaximumTrackTintColor;
}

- (void)setSliderDirection:(CSSliderDirection)sliderDirection {
    _sliderDirection = sliderDirection;
    
    switch (sliderDirection) {
        case CSSliderDirection_Vertical:
            self.transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        default:
            break;
    }
}

- (void)setTrackTintType:(CSSliderTrackTintType)trackTintType {
    _trackTintType = trackTintType;
    
    CGRect frame = CGRectMake(0, (CGRectGetHeight(self.frame) - heightLine) / 2, CGRectGetWidth(self.frame), heightLine);
    
    if (!trackView) {
        trackView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:trackView];
        [self sendSubviewToBack:trackView];
    }
    
    if (!bgView) {
        bgView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:bgView];
        [self sendSubviewToBack:bgView];
    }
    
    switch (trackTintType) {
        case CSSliderTrackTintType_Divide:
            bgView.backgroundColor = [self colorWithLeft:_csMinimumTrackTintColor right:_csMaximumTrackTintColor];
            trackView.backgroundColor = [self colorWithLeft:_csMaximumTrackTintColor right:_csMinimumTrackTintColor];
            break;
        default:
            bgView.backgroundColor = _csMaximumTrackTintColor;
            trackView.backgroundColor = _csMinimumTrackTintColor;
            break;
    }
    
    [self adjustTrackViewViaSliderValue];
}

- (UIColor *)colorWithLeft:(UIColor *)leftColor right:(UIColor *)rightColor {
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect leftRect     = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
    CGContextSetFillColorWithColor(context, leftColor.CGColor);
    CGContextFillRect(context, leftRect);
    
    CGRect rightRect    = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
    CGContextSetFillColorWithColor(context, rightColor.CGColor);
    CGContextFillRect(context, rightRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:image];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self adjustTrackViewViaSliderValue];
}

//  根据value修正trackView的frame
- (void)adjustTrackViewViaSliderValue {
    switch (_trackTintType) {
        case CSSliderTrackTintType_Divide:
        {
            float scale = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
            CGRect rect = trackView.frame;
            // 根据bgView来计算，self的frame因为transform而导致计算不正确。
            rect.size.width = scale * bgView.frame.size.width;
            trackView.frame = rect;
            break;
        }
        default:
        {
            // Linear类型的slider，与Divide类型不一样。
            CGRect trackRect = [self trackRectForBounds:self.bounds];
            CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
            
            CGFloat originalY = (CGRectGetHeight(self.frame) - heightLine) / 2;
            CGFloat offset = 2.0f;
            CGFloat widthTrackView = MAX(CGRectGetMinX(thumbRect) - offset, 0);
            CGFloat widthBgView = MAX(CGRectGetWidth(self.frame) - CGRectGetMaxX(thumbRect) - offset, 0);
            
            if (_sliderDirection == CSSliderDirection_Vertical) {
                originalY = (CGRectGetWidth(self.frame) - heightLine) / 2;
                widthBgView = MAX(CGRectGetHeight(self.frame) - CGRectGetMaxX(thumbRect) - offset, 0);
            }
            
            trackView.frame = CGRectMake(0, originalY, widthTrackView, heightLine);
            bgView.frame = CGRectMake(CGRectGetMaxX(thumbRect) + offset, originalY, widthBgView, heightLine);
            break;
        }
    }
}

#pragma mark - target events

- (void)addTargetEvents {
    [self addTarget:self action:@selector(actionValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(actionTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(actionTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(actionTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(actionTouchCancel:) forControlEvents:UIControlEventTouchCancel];
}

- (void)actionValueChanged:(CSSlider *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(CSSliderValueChanged:)]) {
        [_delegate CSSliderValueChanged:sender];
    }
    
    [self setNeedsDisplay];
}

- (void)actionTouchDown:(CSSlider *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(CSSliderTouchDown:)]) {
        [_delegate CSSliderTouchDown:sender];
    }
}

- (void)actionTouchUp:(CSSlider *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(CSSliderTouchUp:)]) {
        [_delegate CSSliderTouchUp:sender];
    }
}

- (void)actionTouchCancel:(CSSlider *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(CSSliderTouchCancel:)]) {
        [_delegate CSSliderTouchCancel:sender];
    }
}

#pragma mark - value related

- (void)setValue:(float)value {
    [super setValue:value];
    
    [self actionValueChanged:self];
}

- (float)middleVaule {
    return (self.maximumValue - self.minimumValue) / 2;
}

- (void)increasePercentRate:(NSInteger)percent {
    CGFloat sliderSpan = self.maximumValue - self.minimumValue;
    
    NSInteger willPercent = MIN(MAX(1, percent), 100);
    CGFloat willAddValue = (willPercent / 100.0f) * (sliderSpan/2.0);
    CGFloat newValue = self.value + willAddValue;
    newValue =  MIN(MAX(self.minimumValue, newValue), self.maximumValue);
    
    self.value = newValue;
}

- (void)decreasePercentRate:(NSInteger)percent {
    CGFloat sliderSpan = self.maximumValue - self.minimumValue;
    
    NSInteger willPercent = MIN(MAX(1, percent), 100);
    CGFloat willAddValue = (willPercent / 100.0f) * (sliderSpan/2.0f);
    CGFloat newValue = self.value - willAddValue;
    newValue =  MIN(MAX(self.minimumValue, newValue), self.maximumValue);
    
    self.value = newValue;
}

@end
