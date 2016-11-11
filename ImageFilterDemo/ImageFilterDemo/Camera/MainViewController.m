//
//  MainViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/11/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "MainViewController.h"
#import "CSCameraViewController.h"
#import "TestViewController.h"

@interface MainViewController ()
<
    UIScrollViewDelegate
>

@end

@implementation MainViewController
{
    UIScrollView *_horizontalscrollView; // main scrollView
    UIScrollView *_verticalScrollView;
    
    CSCameraViewController *_cameraVC;
    TestViewController *_testVCLeft;
    TestViewController *_testVCRight;
    TestViewController *_testVCUp;
    TestViewController *_testVCDown;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initVerticalScrollView];
    
    [self initHorizontalScrollView];
}

- (void)initVerticalScrollView
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height= self.view.frame.size.height;
    _verticalScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _verticalScrollView.contentSize = CGSizeMake(width, height * 3);
    _verticalScrollView.pagingEnabled = YES;
    _verticalScrollView.bounces = NO;
    _verticalScrollView.delegate = self;
    _verticalScrollView.contentOffset = CGPointMake(0, height);
    
    _testVCUp = [[TestViewController alloc] init];
    _testVCUp.view.backgroundColor = [UIColor yellowColor];
    [self addChildViewController:_testVCUp];
    [_verticalScrollView addSubview:_testVCUp.view];
    _testVCUp.view.frame = CGRectMake(0, 0, width, height);
    
    _testVCDown = [[TestViewController alloc] init];
    _testVCDown.view.backgroundColor = [UIColor greenColor];
    [self addChildViewController:_testVCDown];
    [_verticalScrollView addSubview:_testVCDown.view];
    _testVCDown.view.frame = CGRectMake(0, height * 2, width, height);
    
    //
    _cameraVC = [[CSCameraViewController alloc] init];
    [self addChildViewController:_cameraVC];
    [_verticalScrollView addSubview:_cameraVC.view];
    _cameraVC.view.frame = CGRectMake(0, height, width, height);
    
    // camera的cameraView始终在屏幕中间
    [self.view insertSubview:_cameraVC.cameraView atIndex:0];
}

- (void)initHorizontalScrollView
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height= self.view.frame.size.height;
    _horizontalscrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_horizontalscrollView];
    _horizontalscrollView.contentSize = CGSizeMake(width * 3, height);
    _horizontalscrollView.pagingEnabled = YES;
    _horizontalscrollView.bounces = NO;
    _horizontalscrollView.delegate = self;
    _horizontalscrollView.contentOffset = CGPointMake(width, 0);
    
    _testVCLeft = [[TestViewController alloc] init];
    _testVCLeft.view.backgroundColor = [UIColor redColor];
    [self addChildViewController:_testVCLeft];
    [_horizontalscrollView addSubview:_testVCLeft.view];
    _testVCLeft.view.frame = CGRectMake(0, 0, width, height);
    
    _testVCRight = [[TestViewController alloc] init];
    _testVCRight.view.backgroundColor = [UIColor blueColor];
    [self addChildViewController:_testVCRight];
    [_horizontalscrollView addSubview:_testVCRight.view];
    _testVCRight.view.frame = CGRectMake(width * 2, 0, width, height);
    
    //
    [_horizontalscrollView addSubview:_verticalScrollView];
    _verticalScrollView.frame = CGRectMake(width, 0, width, height);
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height= self.view.frame.size.height;
    if (_verticalScrollView.contentOffset.y == height) {
        _horizontalscrollView.scrollEnabled = YES;
    } else {
        _horizontalscrollView.scrollEnabled = NO;
    }
}

@end
