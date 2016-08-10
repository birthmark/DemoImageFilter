//
//  BeautyCenterViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/9.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "BeautyCenterViewController.h"

@interface BeautyCenterViewController ()

@end

@implementation BeautyCenterViewController {

    UIView *_topBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view.backgroundColor = [UIColor whiteColor];
    
    __block UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PHImageManager defaultManager] requestImageForAsset:_asset
                                                   targetSize:imageView.frame.size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:nil
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        imageView.image = result;
                                                    });
                                                }];
        
    });
    
    [self initTopBar];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)initTopBar {
    _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    _topBar.backgroundColor = [UIColor blackColor];
    _topBar.alpha = 0.5;
    [self.view addSubview:_topBar];
    
    // Close
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnClose setBackgroundImage:[UIImage imageNamed:@"btnClose"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnClose];
}

- (void)actionClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
