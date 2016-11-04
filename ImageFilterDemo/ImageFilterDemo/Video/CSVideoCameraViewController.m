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


#define PreviewViewOffet 29


@interface CSVideoCameraViewController () <

    GPUImageVideoCameraDelegate
>

@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, assign) CGRect faceBounds;

@property (nonatomic, strong) GPUImageUIElement *uiElement;
@property (nonatomic, strong) UIImageView *watermarkImageView;

@end

@implementation CSVideoCameraViewController {
    
    GPUImageView *previewView;
    GPUImageVideoCamera *videoCamera;
    
    GPUImageMovieWriter *movieWriter;
    
    GPUImageOutput <GPUImageInput> *filter;
    
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
    
    previewView.center = CGPointMake(self.view.center.x, self.view.center.y + PreviewViewOffet);
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
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(CSVideoCameraViewControllerDelegateDoneWithVideoPath:)]) {
            [_delegate CSVideoCameraViewControllerDelegateDoneWithVideoPath:videoPath];
        }
    }];
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
    previewView.center = CGPointMake(self.view.center.x, self.view.center.y - PreviewViewOffet);
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view insertSubview:previewView atIndex:0];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    videoCamera.delegate = self;
    
    // 不加滤镜
//    [stillCamera addTarget:previewView];
    //
    
    // 添加水印
    UIView *view = [[UIView alloc] initWithFrame:previewView.bounds];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 200, 30)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:30.f];
    label.text = @"这是水印";
    [view addSubview:label];
    
    _watermarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    _watermarkImageView.image = [UIImage imageNamed:@"ear.png"];
    _watermarkImageView.contentMode = UIViewContentModeScaleToFill;
    _watermarkImageView.center = view.center;
    [view addSubview:_watermarkImageView];
    
    _uiElement = [[GPUImageUIElement alloc] initWithView:view];
    
    // filter和uiElement都输入至blendFilter，然后输出至preview即可。
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.f;
    
    // 视频添加滤镜
    filter = [[GPUImageFilter alloc] init];
    [videoCamera addTarget:filter];
    
    // 添加输入至blendFilter
    [filter addTarget:blendFilter];
    [_uiElement addTarget:blendFilter];
    
    // blendFilter输出至preview
    [blendFilter addTarget:previewView];
//    [filter addTarget:previewView];
    
    __weak typeof(self) weakSelf = self;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime) {
        // 根据得到的faceBounds来更新水印的位置
        CGFloat centerXFace = CGRectGetMinX(weakSelf.faceBounds) + CGRectGetWidth(weakSelf.faceBounds) / 2;
        // 因为图片的原因要加offset
        weakSelf.watermarkImageView.center = CGPointMake(centerXFace, CGRectGetMinY(weakSelf.faceBounds) - CGRectGetHeight(weakSelf.watermarkImageView.frame) / 2 + 50);
        
        // 一定要update
        [weakSelf.uiElement update];
    }];
    
    [videoCamera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CFAllocatorRef allocator = CFAllocatorGetDefault();
    CMSampleBufferRef sampleBufferRef;
    CMSampleBufferCreateCopy(allocator, sampleBuffer, &sampleBufferRef);
    [self performSelectorInBackground:@selector(faceDetecting:) withObject:CFBridgingRelease(sampleBufferRef)];
}

// 参考博客：http://www.jianshu.com/p/ba1f79f8f6fa
- (CIDetector *)faceDetector
{
    if (!_faceDetector) {
        NSDictionary *options = @{
                                  CIDetectorAccuracy: CIDetectorAccuracyLow
                                  };
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    }
    return _faceDetector;
}

- (void)faceDetecting:(CMSampleBufferRef)sampleBuffer
{
    // 将摄像头数据转换成CIImage，对其使用CIDetector进行人脸检测
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    if (attachments)
        CFRelease(attachments);
    NSDictionary *imageOptions = nil;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    int exifOrientation;
    
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    BOOL isUsingFrontFacingCamera = FALSE;
    AVCaptureDevicePosition currentCameraPosition = [videoCamera cameraPosition];
    
    if (currentCameraPosition != AVCaptureDevicePositionBack)
    {
        isUsingFrontFacingCamera = TRUE;
    }
    
    switch (curDeviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    
    imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    // 得到CIFaceFeature，根据其计算出人脸的位置，从而调整水印的位置。
    NSArray *features = [self.faceDetector featuresInImage:convertedImage options:imageOptions];
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
    
    [self willOutputFeatures:features forClap:clap withOrientation:curDeviceOrientation];
}

- (void)willOutputFeatures:(NSArray *)features forClap:(CGRect)clap withOrientation:(UIDeviceOrientation)curDeviceOrientation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect previewBox = previewView.frame;
        if (features.count) {
            self.watermarkImageView.hidden = NO;
        } else {
            self.watermarkImageView.hidden = YES;
        }
        
        for (CIFaceFeature *faceFeature in features) {
            // find the correct position for the square layer within the previewLayer
            // the feature box originates in the bottom left of the video frame.
            // (Bottom right if mirroring is turned on)
            //Update face bounds for iOS Coordinate System
            CGRect faceRect = faceFeature.bounds;
            
            // flip preview width and height
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
            CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;
            
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            
            //mirror
            CGRect rect = CGRectMake(previewBox.size.width - faceRect.origin.x - faceRect.size.width, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
            if (fabs(rect.origin.x - self.faceBounds.origin.x) > 5.0) {
                self.faceBounds = rect;
                //                if (self.faceView) {
                //                    [self.faceView removeFromSuperview];
                //                    self.faceView =  nil;
                //                }
                //
                //                // create a UIView using the bounds of the face
                //                self.faceView = [[UIView alloc] initWithFrame:self.faceBounds];
                //
                //                // add a border around the newly created UIView
                //                self.faceView.layer.borderWidth = 1;
                //                self.faceView.layer.borderColor = [[UIColor redColor] CGColor];
                //
                //                // add the new view to create a box around the face
                //                [self.view addSubview:self.faceView];
            }
        }
    });
}

@end
