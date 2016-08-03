//
//  CSVideoCameraViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSVideoCameraViewController.h"

#import "CSViewVideoCameraDuration.h"

#import "GPUImage.h"


@interface CSVideoCameraViewController () <

    GPUImageVideoCameraDelegate
>

@end

@implementation CSVideoCameraViewController {
    
    GPUImageView *previewView;
    GPUImageVideoCamera *videoCamera;
    
    GPUImageMovieWriter *movieWriter;
    
    GPUImageFilter *filter;
    
    NSString *videoPath;
    
    CSViewVideoCameraDuration *viewVideoDuration;
    
    UIView *topBar;
    UIView *toolBar;
    
    BOOL isCapturingVideo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initVideoCameraView];
    
    [self initTopBar];
    [self initToolBar];
    
    [self initVideoTimeLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    previewView.center = CGPointMake(previewView.center.x, previewView.center.y + 30);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Top Bar

- (void)initTopBar {
    topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
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
    if (isCapturingVideo) {
        [self stopVideoCapture];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionRotate:(UIButton *)sender {
    [videoCamera rotateCamera];
}

#pragma mark - Tool Bar

- (void)initToolBar {
    toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 100, CGRectGetWidth(self.view.frame), 100)];
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
    isCapturingVideo = !isCapturingVideo;
    
    if (isCapturingVideo) {
    
    } else {
        [self stopVideoCapture];
        return;
    }
    
    [self startVideoCapture];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((MAX_VIDEO_DURATION - 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self stopVideoCapture];
    });
}

- (void)startVideoCapture {
    [viewVideoDuration startVideoCapture];
    
    // MovieWriter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd h:m:s"];
    NSString *videoName = [dateFormatter stringFromDate:[NSDate date]];
    
    videoPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    videoPath = [videoPath stringByAppendingString:[NSString stringWithFormat:@"/%@.mp4", videoName]];
//    unlink([videoPath UTF8String]); // 先释放该路径的文件
    NSURL *movieURL = [NSURL fileURLWithPath:videoPath];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480, 640)];
    movieWriter.encodingLiveVideo = YES;
    [filter addTarget:movieWriter];
    
    videoCamera.audioEncodingTarget = movieWriter;
    movieWriter.shouldPassthroughAudio = YES;
    [movieWriter startRecording];
}

- (void)stopVideoCapture {
    isCapturingVideo = NO;
    
    [viewVideoDuration stopVideoCapture];
    
    [filter removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    [movieWriter finishRecording];
}

- (void)actionAlbum:(UIButton *)sender {
    if (isCapturingVideo) {
        [self stopVideoCapture];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(CSVideoCameraViewControllerDelegateActionAlbum)]) {
            [_delegate CSVideoCameraViewControllerDelegateActionAlbum];
        }
    }];
}

- (void)actionProportion:(UIButton *)sender {
    
}

- (void)actionFilter:(UIButton *)sender {
    
}

#pragma mark - Video Timer

- (void)initVideoTimeLabel {
    viewVideoDuration = [[CSViewVideoCameraDuration alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(topBar.frame), CGRectGetWidth(previewView.frame), 30)];
    [self.view addSubview:viewVideoDuration];
}

#pragma mark - VideoCamera View

- (void)initVideoCameraView {
    previewView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    // 保持与iOS系统相机的位置一致。
    previewView.center = CGPointMake(previewView.center.x, previewView.center.y - 30);
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view insertSubview:previewView atIndex:0];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    videoCamera.delegate = self;
    
    // 不加滤镜
//    [stillCamera addTarget:previewView];
    //
    
    // 添加滤镜
    filter = [[GPUImageSepiaFilter alloc] init];
    [filter addTarget:previewView];

    [videoCamera addTarget:filter];
    //
    
    [videoCamera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

@end
