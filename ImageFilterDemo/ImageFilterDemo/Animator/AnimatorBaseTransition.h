//
//  AnimatorBaseTransition.h
//  DemoTransitions
//
//  Created by Chris Hu on 16/7/17.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AnimatorTransitionType) {
    kAnimatorTransitionTypePresent = 0,
    kAnimatorTransitionTypeDismiss,
    kAnimatorTransitionTypePush,
    kAnimatorTransitionTypePop,
};

@interface AnimatorBaseTransition : NSObject <

    UIViewControllerAnimatedTransitioning
>


@property (nonatomic, assign) AnimatorTransitionType animatorTransitionType;


@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIViewController *from;
@property (nonatomic, strong) UIViewController *to;

@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, strong) UIView *toView;


@end
