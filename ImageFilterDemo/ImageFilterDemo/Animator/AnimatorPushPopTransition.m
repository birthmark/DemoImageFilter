//
//  AnimatorPushPopTransition.m
//  DemoTransitions
//
//  Created by Chris Hu on 16/7/18.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "AnimatorPushPopTransition.h"

@implementation AnimatorPushPopTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransition:transitionContext];
}

- (void)animationPush {
    [self.containerView addSubview:self.toView];
    
    self.toView.transform = CGAffineTransformMakeTranslation(self.toView.frame.size.width, 0);
    
    NSTimeInterval duration = [self transitionDuration:self.transitionContext];
    typeof (&*self) __weak weakSelf = self;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.toView.transform = CGAffineTransformIdentity;
        self.fromView.transform = CGAffineTransformMakeTranslation(-self.fromView.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        
        self.fromView.transform = CGAffineTransformIdentity;
        
        [weakSelf.transitionContext completeTransition:![weakSelf.transitionContext transitionWasCancelled]];
    }];
}

- (void)animationPop {
    [self.containerView addSubview:self.toView];
    
    self.toView.transform = CGAffineTransformMakeTranslation(-self.toView.frame.size.width, 0);
    
    NSTimeInterval duration = [self transitionDuration:self.transitionContext];
    typeof (&*self) __weak weakSelf = self;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.toView.transform = CGAffineTransformIdentity;
        self.fromView.transform = CGAffineTransformMakeTranslation(self.fromView.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        
        self.fromView.transform = CGAffineTransformIdentity;
        
        [weakSelf.transitionContext completeTransition:![weakSelf.transitionContext transitionWasCancelled]];
    }];
}

- (void)animationEnded:(BOOL) transitionCompleted {
    NSLog(@"%s", __func__);
}

@end
