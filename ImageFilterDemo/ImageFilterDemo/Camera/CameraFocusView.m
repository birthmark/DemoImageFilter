//
//  CameraFocusView.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/9/8.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CameraFocusView.h"

@interface CameraFocusView ()

@property (nonatomic, strong) UIImageView *focusView_big;
@property (nonatomic, strong) UIImageView *focusView_small;

@end

@implementation CameraFocusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _focusView_big = [[UIImageView alloc] initWithFrame:self.frame];
        _focusView_big.image = [UIImage imageNamed:@"focus_big"];
        _focusView_big.center = self.center;
        [self addSubview:_focusView_big];
        
        _focusView_small = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
        _focusView_small.image = [UIImage imageNamed:@"focus_small"];
        _focusView_small.center = self.center;
        [self addSubview:_focusView_small];
    }
    return self;
}

- (void)beginAnimation {
    [self endAnimation];
    
    CATransform3D tf_1 = CATransform3DMakeScale(0.6f, 0.6f, 1.0f);
    CATransform3D tf_2 = CATransform3DIdentity;
    CATransform3D tf_3 = CATransform3DMakeScale(0.85, 0.85, 1.0f);
    CATransform3D tf_4 = CATransform3DIdentity;
    
    
    NSArray *scaleArray = [NSArray arrayWithObjects:
                           [NSValue valueWithCATransform3D:tf_1],
                           [NSValue valueWithCATransform3D:tf_2],
                           [NSValue valueWithCATransform3D:tf_3],
                           [NSValue valueWithCATransform3D:tf_4],
                           nil];
    
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 1.0f;
    animation.keyTimes = @[@(0.0f),@(0.33f),@(0.66),@(1.0)];
    animation.values = scaleArray;
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation.delegate = self;
    [animation setRemovedOnCompletion:NO];
    animation.fillMode = kCAFillModeForwards;
    
    [_focusView_big.layer addAnimation:animation forKey:@"kTransformAnimation"];
}

- (void)endAnimation {
    [_focusView_big.layer removeAnimationForKey:@"kTransformAnimation"];
    [_focusView_big.layer removeAllAnimations];
    [self.layer removeAllAnimations];
}

- (void)animationDidStart:(CAAnimation *)anim {
    _focusView_big.alpha = 1.0f;
    _focusView_small.alpha = 1.0f;
    self.alpha = 1.0f;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim isKindOfClass:[CAKeyframeAnimation class]]) {
        if (!flag) {
            return;
        }
        
        [UIView animateWithDuration:0.1f animations:^{
            _focusView_big.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
            if (!finished) {
                return;
            }
            
            [_focusView_big.layer removeAnimationForKey:@"kTransformAnimation"];
            [_focusView_big.layer removeAllAnimations];
            
            [UIView animateWithDuration:0.2f animations:^{
                _focusView_small.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.alpha = 0.0f;
            }];
        }];
    }
}

@end
