//
//  CSCameraView.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSCameraView.h"
#import "GPUImage.h"

@interface CSCameraView () <

    GPUImageVideoCameraDelegate
>


@end

@implementation CSCameraView {

    GPUImageStillCamera *stillCamera;
    
    GPUImageFilter *filter;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCameraView];
        
        [self initTopBar];
        [self initToolBar];
    }
    return self;
}

#pragma mark - Top Bar

- (void)initTopBar {
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 60)];
    topBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:topBar];
    
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
    
    UIButton *btnRotate = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 60, 0, 60, 30)];
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
    [self removeFromSuperview];
}

- (void)actionSettings:(UIButton *)sender {
    [self actionCapture:nil];
}

- (void)actionRotate:(UIButton *)sender {
    [stillCamera rotateCamera];
}

#pragma mark - Tool Bar

- (void)initToolBar {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 75, CGRectGetWidth(self.frame), 75)];
    toolBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:toolBar];
    
    UIButton *btnCapture = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [btnCapture setTitle:@"Capture" forState:UIControlStateNormal];
    [btnCapture setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnCapture setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btnCapture addTarget:self action:@selector(actionCapture:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnCapture];
    
    btnCapture.center = CGPointMake(toolBar.center.x, CGRectGetHeight(toolBar.frame) / 2);
}

- (void)actionCapture:(UIButton *)sender {
    [stillCamera capturePhotoAsImageProcessedUpToFilter:filter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (error == nil) {
            NSLog(@"complete");
            
            UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
        }
    }];
}

#pragma mark - Camera View

- (void)initCameraView {
    GPUImageView *previewView = [[GPUImageView alloc] initWithFrame:self.frame];
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self insertSubview:previewView atIndex:0];

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
