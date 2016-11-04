//
//  MainViewController.m
//  ImageFilterDemo
//
//  Created by zj－db0465 on 16/11/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "MainViewController.h"
#import "CSCameraViewController.h"
#import "TestViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    UIScrollView *_scrollViewVertical;
    UIScrollView *_scrollViewHorizontal;
    
    CSCameraViewController *_cameraVC;
    TestViewController *_testVC;
    TestViewController *_testVCUp;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCameraVC];
    [self initScrollViewHorizontal];
//    [self initScrollViewVertical];
}

- (void)initCameraVC
{
    _cameraVC = [[CSCameraViewController alloc] init];
    [self addChildViewController:_cameraVC];
    [self.view addSubview:_cameraVC.view];
}

- (void)initScrollViewHorizontal
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height= self.view.frame.size.height;
    _scrollViewHorizontal = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_scrollViewHorizontal];
    _scrollViewHorizontal.contentSize = CGSizeMake(width * 2, height);
    _scrollViewHorizontal.pagingEnabled = YES;
    _scrollViewHorizontal.bounces = NO;
    _scrollViewHorizontal.delegate = self;
    
    _testVC = [[TestViewController alloc] init];
    [self addChildViewController:_testVC];
    
    [_scrollViewHorizontal addSubview:_testVC.view];
    _testVC.view.frame = CGRectMake(width, 0, width, height);
}

- (void)initScrollViewVertical
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height= self.view.frame.size.height;
    _scrollViewVertical = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_scrollViewVertical];
    _scrollViewVertical.contentSize = CGSizeMake(width, height * 2);
    _scrollViewVertical.pagingEnabled = YES;
    _scrollViewVertical.bounces = NO;
    
    _testVCUp = [[TestViewController alloc] init];
    [self addChildViewController:_testVCUp];
    
    [_scrollViewVertical addSubview:_testVCUp.view];
    _testVCUp.view.frame = CGRectMake(height, 0, width, height);
}

@end
