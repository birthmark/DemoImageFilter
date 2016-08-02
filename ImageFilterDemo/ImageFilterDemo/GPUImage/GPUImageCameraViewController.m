//
//  GPUImageCameraViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "GPUImageCameraViewController.h"

#import "CSCameraView.h"

@interface GPUImageCameraViewController ()

@end

@implementation GPUImageCameraViewController {
    
    UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addBtnBack];
    
    [self addBtns];
    
    [self addUIImageView];
}

- (void)addBtnBack{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 30)];
    [btn setTitle:@"Close" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addBtns {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 50)];
    [btn setTitle:@"Camera" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionCamera:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionCamera:(UIButton *)sender {
    CSCameraView *cameraView = [[CSCameraView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:cameraView];
}

- (void)addUIImageView {
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
}

@end
