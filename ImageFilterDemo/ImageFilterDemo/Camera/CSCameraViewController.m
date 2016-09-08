//
//  CSCameraViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSCameraViewController.h"

#import "GPUImage.h"
#import "CameraFocusView.h"

#define PreviewViewOffet 29


typedef NS_ENUM(NSInteger, CameraProportionType) {
    CameraProportionType11,
    CameraProportionType34,
    CameraProportionTypeFill,
};


@interface CSCameraViewController () <

    GPUImageVideoCameraDelegate
>

@end

@implementation CSCameraViewController {
    
    GPUImageView *previewView;
    GPUImageStillCamera *stillCamera;
    
    GPUImageFilter *filter;
    
    NSInteger cameraProportionType;
    
    CameraFocusView *cameraFocusView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCameraView];
    
    [self initTopBar];
    [self initToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self listenAVCaptureDeviceSubjectAreaDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    previewView.center = CGPointMake(self.view.center.x, self.view.center.y + PreviewViewOffet);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Top Bar

- (void)initTopBar {
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    topBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topBar];
    
    // Settings
    UIButton *btnSettings = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnSettings setBackgroundImage:[UIImage imageNamed:@"btnSettings"] forState:UIControlStateNormal];
    [btnSettings addTarget:self action:@selector(actionSettings:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnSettings];
    
    // Close
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnClose setBackgroundImage:[UIImage imageNamed:@"btnClose"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnClose];
    
    // Rotate
    UIButton *btnRotate = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(topBar.frame) - 40, 0, 40, 40)];
    [btnRotate setBackgroundImage:[UIImage imageNamed:@"btnRotate"] forState:UIControlStateNormal];
    [btnRotate addTarget:self action:@selector(actionRotate:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnRotate];
    
    btnSettings.center  = topBar.center;
    btnClose.center     = CGPointMake(btnClose.center.x, btnSettings.center.y);
    btnRotate.center    = CGPointMake(btnRotate.center.x, btnSettings.center.y);
}

- (void)actionSettings:(UIButton *)sender {
    
}

- (void)actionClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionRotate:(UIButton *)sender {
    [stillCamera rotateCamera];
}

#pragma mark - Tool Bar

- (void)initToolBar {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 100, CGRectGetWidth(self.view.frame), 100)];
    toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBar];
    
    // Capture
    UIButton *btnCapture = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    [btnCapture setBackgroundImage:[UIImage imageNamed:@"btnCapture"] forState:UIControlStateNormal];
    [btnCapture setBackgroundImage:[UIImage imageNamed:@"btnCaptureHighlighted"] forState:UIControlStateHighlighted];
    [btnCapture addTarget:self action:@selector(actionCapture:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnCapture];
    
    // Album
    UIButton *btnAlbum = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    [btnAlbum setBackgroundImage:[UIImage imageNamed:@"Model.png"] forState:UIControlStateNormal];
    [btnAlbum addTarget:self action:@selector(actionAlbum:) forControlEvents:UIControlEventTouchUpInside];
    btnAlbum.layer.cornerRadius = 5.0f;
    btnAlbum.layer.masksToBounds = YES;
    [toolBar addSubview:btnAlbum];
    
    // Proportion
    UIButton *btnProportion = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnAlbum.frame) + 20, 0, 40, 40)];
    [btnProportion setBackgroundImage:[UIImage imageNamed:@"btnProportion11"] forState:UIControlStateNormal];
    [btnProportion addTarget:self action:@selector(actionProportion:) forControlEvents:UIControlEventTouchUpInside];
    btnProportion.layer.cornerRadius = 5.0f;
    btnProportion.layer.masksToBounds = YES;
    [toolBar addSubview:btnProportion];
    
    // Filter
    UIButton *btnFilter = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(toolBar.frame) - 40 - 10, 0, 40, 40)];
    [btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter"] forState:UIControlStateNormal];
    [btnFilter addTarget:self action:@selector(actionFilter:) forControlEvents:UIControlEventTouchUpInside];
    btnFilter.layer.cornerRadius = 5.0f;
    btnFilter.layer.masksToBounds = YES;
    [toolBar addSubview:btnFilter];
    
    btnCapture.center       = CGPointMake(toolBar.center.x, CGRectGetHeight(toolBar.frame) / 2);
    btnAlbum.center         = CGPointMake(btnAlbum.center.x, btnCapture.center.y);
    btnProportion.center    = CGPointMake(CGRectGetMaxX(btnAlbum.frame) + (CGRectGetMinX(btnCapture.frame) - CGRectGetMaxX(btnAlbum.frame))/2, btnCapture.center.y);
    btnFilter.center        = CGPointMake(btnFilter.center.x, btnCapture.center.y);
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

- (void)actionProportion:(UIButton *)sender {
    CGFloat width = previewView.frame.size.width;
    switch (cameraProportionType) {
        case CameraProportionType11:
            cameraProportionType = CameraProportionType34;
            break;
        case CameraProportionType34:
            cameraProportionType = CameraProportionTypeFill;
            break;
        case CameraProportionTypeFill:
            cameraProportionType = CameraProportionType11;
            break;
        default:
            break;
    }
}

- (void)actionFilter:(UIButton *)sender {
    
}

#pragma mark - Camera View

- (void)initCameraView {
    previewView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    // 保持与iOS系统相机的位置一致。
    previewView.center = CGPointMake(self.view.center.x, self.view.center.y - PreviewViewOffet);
    cameraProportionType = CameraProportionType34;
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view insertSubview:previewView atIndex:0];
    
    [self addFocusTapGesture];
    
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    stillCamera.delegate = self;
    
    // TODO: 不加滤镜, 如何获取图片？
//        [stillCamera addTarget:previewView];
    //
    
    // 添加滤镜
    
    // GPUImageStillCamera (output) -> GPUImageFilter (input, output) -> GPUImageView (input)
    // GPUImagePicture (output)     —> GPUImageFilter (input, output) —> GPUImageView (input)

//    filter = [[GPUImageSepiaFilter alloc] init];
    
    // TODO: 使用LUT的滤镜没有效果。原因未知。
     filter = [[GPUImageAmatorkaFilter alloc] init];
    [filter addTarget:previewView];

    [stillCamera addTarget:filter];
    
    // 添加滤镜
    
    [stillCamera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

- (void)addFocusTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionFocus:)];
    [previewView addGestureRecognizer:tapGesture];
}

- (void)actionFocus:(UITapGestureRecognizer *)sender {
    CGPoint touchpoint = [sender locationInView:previewView];
    
    if (!stillCamera.inputCamera.isFocusPointOfInterestSupported ||
        !stillCamera.inputCamera.isExposurePointOfInterestSupported) {
        return;
    }
    
    if (!cameraFocusView) {
        cameraFocusView = [[CameraFocusView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.view addSubview:cameraFocusView];
    }
    cameraFocusView.center = touchpoint;
    
    
    [cameraFocusView beginAnimation];
    
    [stillCamera.inputCamera lockForConfiguration:nil];
    
    // 需要同时设置focusMode为AVCaptureFocusModeAutoFocus
    stillCamera.inputCamera.focusPointOfInterest = touchpoint;
    stillCamera.inputCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    stillCamera.inputCamera.exposurePointOfInterest = touchpoint;
    stillCamera.inputCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    [stillCamera.inputCamera unlockForConfiguration];
}

- (void)listenAVCaptureDeviceSubjectAreaDidChangeNotification {
    [stillCamera.inputCamera lockForConfiguration:nil];
    stillCamera.inputCamera.subjectAreaChangeMonitoringEnabled = YES;
    [stillCamera.inputCamera unlockForConfiguration];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionAVCaptureDeviceSubjectAreaDidChange:)
                                                 name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                               object:nil];
}

- (void)actionAVCaptureDeviceSubjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self setupFocusMode:AVCaptureFocusModeContinuousAutoFocus
              exposeMode:AVCaptureExposureModeContinuousAutoExposure
                 atPoint:devicePoint
    subjectAreaChangeMonitoringEnabled:YES];
}

- (void)setupFocusMode:(AVCaptureFocusMode)focusMode exposeMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point subjectAreaChangeMonitoringEnabled:(BOOL)subjectAreaChangeMonitoringEnabled {
    
    if ([stillCamera.inputCamera lockForConfiguration:nil]) {
        if (stillCamera.inputCamera.isFocusPointOfInterestSupported) {
            stillCamera.inputCamera.focusPointOfInterest = point;
            stillCamera.inputCamera.focusMode = focusMode;
        }
        
        if (stillCamera.inputCamera.isExposurePointOfInterestSupported) {
            stillCamera.inputCamera.exposurePointOfInterest = point;
            stillCamera.inputCamera.exposureMode = exposureMode;
        }
        
        stillCamera.inputCamera.subjectAreaChangeMonitoringEnabled = subjectAreaChangeMonitoringEnabled;
        [stillCamera.inputCamera unlockForConfiguration];
    }
}

@end
