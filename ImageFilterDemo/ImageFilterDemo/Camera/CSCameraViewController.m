//
//  CSCameraViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSCameraViewController.h"

#import "GPUImage.h"

@interface CSCameraViewController () <

    GPUImageVideoCameraDelegate
>

@end

@implementation CSCameraViewController {
    
    GPUImageStillCamera *stillCamera;
    
    GPUImageFilter *filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCameraView];
    
    [self initTopBar];
    [self initToolBar];
}

#pragma mark - Top Bar

- (void)initTopBar {
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
    topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBar];
    
    UIButton *btnSettings = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [btnSettings setTitle:@"Settings" forState:UIControlStateNormal];
    [btnSettings setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnSettings setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btnSettings addTarget:self action:@selector(actionSettings:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnSettings];
    
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnClose];
    
    UIButton *btnRotate = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(topBar.frame) - 60, 0, 60, 30)];
    [btnRotate setTitle:@"Rotate" forState:UIControlStateNormal];
    [btnRotate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnRotate setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btnRotate addTarget:self action:@selector(actionRotate:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnRotate];
    
    btnSettings.center  = topBar.center;
    btnClose.center     = CGPointMake(btnClose.center.x, btnSettings.center.y);
    btnRotate.center    = CGPointMake(btnRotate.center.x, btnSettings.center.y);
}

- (void)actionClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSettings:(UIButton *)sender {
    
}

- (void)actionRotate:(UIButton *)sender {
    [stillCamera rotateCamera];
}

#pragma mark - Tool Bar

- (void)initToolBar {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 75, CGRectGetWidth(self.view.frame), 75)];
    toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBar];
    
    UIButton *btnCapture = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [btnCapture setTitle:@"Capture" forState:UIControlStateNormal];
    [btnCapture setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnCapture setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btnCapture addTarget:self action:@selector(actionCapture:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnCapture];
    
    UIButton *btnAlbum = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
    [btnAlbum setBackgroundImage:[UIImage imageNamed:@"Model.png"] forState:UIControlStateNormal];
    [btnAlbum addTarget:self action:@selector(actionAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnAlbum];
    
    btnCapture.center   = CGPointMake(toolBar.center.x, CGRectGetHeight(toolBar.frame) / 2);
    btnAlbum.center     = CGPointMake(btnAlbum.center.x, btnCapture.center.y);
    
}

- (void)actionCapture:(UIButton *)sender {
    [stillCamera capturePhotoAsImageProcessedUpToFilter:filter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (error == nil) {
            UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                if (_delegate && [_delegate respondsToSelector:@selector(CSCameraViewControllerDelegateDoneWithImage:)]) {
                    [_delegate CSCameraViewControllerDelegateDoneWithImage:processedImage];
                }
                
            }];
        }
    }];
}

- (void)actionAlbum:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(CSCameraViewControllerDelegateActionAlbum)]) {
            [_delegate CSCameraViewControllerDelegateActionAlbum];
        }
    }];
}

#pragma mark - Camera View

- (void)initCameraView {
    GPUImageView *previewView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view insertSubview:previewView atIndex:0];
    
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    stillCamera.delegate = self;
    
    // 不加滤镜
    //    [stillCamera addTarget:previewView];
    //
    
    // 添加滤镜
    filter = [[GPUImageSepiaFilter alloc] init];
    [filter addTarget:previewView];
    
    [stillCamera addTarget:filter];
    //
    
    [stillCamera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

@end
