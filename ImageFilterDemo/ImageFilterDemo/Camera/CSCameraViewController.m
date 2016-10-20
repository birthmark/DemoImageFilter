//
//  CSCameraViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSCameraViewController.h"

#import "CLLocation+GPSDictionary.h"

#import "GPUImage.h"
#import "GPUImageMoonlightFilter.h"
#import "CameraFocusView.h"
#import "CSSlider.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+CSCategory.h"

typedef NS_ENUM(NSInteger, CameraProportionType) {
    CameraProportionType11,
    CameraProportionType34,
    CameraProportionTypeFill,
};


@interface CSCameraViewController () <

    GPUImageVideoCameraDelegate,
    CSSliderDelegate,
    CLLocationManagerDelegate
>

@end

@implementation CSCameraViewController {
    
    GPUImageView *previewView;
    GPUImageStillCamera *stillCamera;
    
    GPUImageFilterGroup *_filterGroup;
    GPUImageFilterPipeline *_filterPipeline;
    
    GPUImageFilter *filter;
    
    NSInteger cameraProportionType;
    
    CameraFocusView *cameraFocusView;
    UIView *_maskViewCapture;
    
    CSSlider *csSlider;
    
    UIView *topBar;
    UIView *toolBar;
    
    UIView *_viewAlbumThumbnail;
    UIImageView *_thumbnailAlbum;
    UIButton *_btnAlbumThumbnail;
    UIActivityIndicatorView *_activityIndicator;
    
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCameraView];
    
    [self initExposureSlider];
    
    [self initTopBar];
    [self initToolBar];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [stillCamera startCameraCapture];
    
    [self listenAVCaptureDeviceSubjectAreaDidChangeNotification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_locationManager requestAlwaysAuthorization];
    
    [_locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [stillCamera stopCameraCapture];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    
    [_locationManager stopUpdatingLocation];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [self updateLayoutAfterRotationViaSize:size];
}

- (void)updateLayoutAfterRotationViaSize:(CGSize)size {
    NSLog(@"%@", NSStringFromCGSize(size));
//    previewView.frame = CGRectMake(0, 0, size.width, size.height);
//    topBar.frame = CGRectMake(0, 0, size.width, 40);
//    toolBar.frame = CGRectMake(0, size.height - 100, size.width, 100);
}

#pragma mark - Top Bar

- (void)initTopBar {
    topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    topBar.backgroundColor = [UIColor clearColor];
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
    toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 100, CGRectGetWidth(self.view.frame), 100)];
    toolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:toolBar];
    
    // Capture
    UIButton *btnCapture = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    [btnCapture setBackgroundImage:[UIImage imageNamed:@"btnCapture"] forState:UIControlStateNormal];
    [btnCapture setBackgroundImage:[UIImage imageNamed:@"btnCaptureHighlighted"] forState:UIControlStateHighlighted];
    [btnCapture addTarget:self action:@selector(actionCapture:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnCapture];
    
    // Album
    _viewAlbumThumbnail = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    _viewAlbumThumbnail.layer.borderColor= [UIColor whiteColor].CGColor;
    _viewAlbumThumbnail.layer.borderWidth = 1.f;
    _viewAlbumThumbnail.layer.cornerRadius = 2.0f;
    _viewAlbumThumbnail.layer.masksToBounds = YES;
    [toolBar addSubview:_viewAlbumThumbnail];
    
    _thumbnailAlbum = [[UIImageView alloc] initWithFrame:_viewAlbumThumbnail.bounds];
    _thumbnailAlbum.image = [UIImage imageNamed:@"Model.png"];
    [_viewAlbumThumbnail addSubview:_thumbnailAlbum];
    
    _btnAlbumThumbnail = [[UIButton alloc] initWithFrame:_viewAlbumThumbnail.bounds];
    [_btnAlbumThumbnail addTarget:self action:@selector(actionAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [_viewAlbumThumbnail addSubview:_btnAlbumThumbnail];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:_viewAlbumThumbnail.bounds];
    [_viewAlbumThumbnail addSubview:_activityIndicator];
    
    // Proportion
    UIButton *btnProportion = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_btnAlbumThumbnail.frame) + 20, 0, 40, 40)];
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
    _viewAlbumThumbnail.center         = CGPointMake(_btnAlbumThumbnail.center.x, btnCapture.center.y);
    btnProportion.center    = CGPointMake(CGRectGetMaxX(_btnAlbumThumbnail.frame) + (CGRectGetMinX(btnCapture.frame) - CGRectGetMaxX(_btnAlbumThumbnail.frame))/2, btnCapture.center.y);
    btnFilter.center        = CGPointMake(btnFilter.center.x, btnCapture.center.y);
}

- (UIImage *)imageWithData:(NSData *)imageData metadata:(NSDictionary *)metadata
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    NSMutableDictionary * sourceDic = [NSMutableDictionary dictionary];
    NSDictionary *source_metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    [sourceDic addEntriesFromDictionary: metadata];
    [sourceDic addEntriesFromDictionary:source_metadata];
    
    NSMutableData *dest_data = [NSMutableData data];
    CFStringRef UTI = CGImageSourceGetType(source);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1,NULL);
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)sourceDic);
    CGImageDestinationFinalize(destination);
    CFRelease(source);
    CFRelease(destination);
    return [UIImage imageWithData: dest_data];
    
    /*
     //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
     CGImageDestinationAddImageFromSource(destination, imgSource, 0, (__bridge CFDictionaryRef)metadata);
     
     BOOL success = CGImageDestinationFinalize(destination);
     
     if(!success) {
     NSLog(@"***Could not create data from image destination ***");
     }
     
     //            CGImageRef img = CGImageSourceCreateImageAtIndex(imgSource, 0, NULL);
     ////            CGContextRef ctx = UIGraphicsGetCurrentContext();
     //
     //            UIImage *dstImage = [UIImage imageWithCGImage:img];
     
     NSData *newData = [self writeMetadataIntoImageData:imageData metadata:metadata];
     
     UIImage *dstImage = [UIImage imageWithData:newData];
     
     CFRelease(imgSource);
     CFRelease(destination);
     
     
     
     CIImage *ciImage = [CIImage imageWithCGImage:[dstImage CGImage]];
     NSDictionary *info = ciImage.properties;
     */
}

- (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        UIImage *image = [self imageWithData:imageData metadata:metadata];
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError *error) {
    }];
}

- (void)saveImageToCameraRoll:(UIImage*)image location:(CLLocation*)location
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        newAssetRequest.location = location;
        newAssetRequest.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
    }];
}

- (NSDictionary *)metadataForImage:(UIImage *)image withCLLocation:(CLLocation *)location
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
    
    CGImageSourceRef imgSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    //this is the type of image (e.g., public.jpeg)
    CFStringRef UTI = CGImageSourceGetType(imgSource);
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *newImageData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1, NULL);
    
    if(!destination) {
        NSLog(@"***Could not create image destination ***");
        return nil;
    }
    
    //get original metadata
    //            NSDictionary *dict = [_mediaInfoobjectForKey:UIImagePickerControllerMediaMetadata];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    
    NSDictionary *gpsDict = [location GPSDictionary];
    if (metadata && gpsDict) {
        [metadata setValue:gpsDict forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }

    return metadata;
}

#pragma mark - Capture

- (void)actionCapture:(UIButton *)sender {
    if (![UIApplication sharedApplication].isIgnoringInteractionEvents) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    [stillCamera capturePhotoAsImageProcessedUpToFilter:filter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
        _thumbnailAlbum.image = nil;
        _maskViewCapture.hidden = NO;
        [stillCamera pauseCameraCapture];
        
        [_activityIndicator startAnimating];
        
        if (error == nil) {
            
            [stillCamera resumeCameraCapture];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_activityIndicator stopAnimating];
                _maskViewCapture.hidden = YES;
                
                _thumbnailAlbum.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                UIImage *imgAlbumThumbnail = [processedImage cs_imageFitTargetSize:_viewAlbumThumbnail.frame.size];
                _thumbnailAlbum.image = imgAlbumThumbnail;
                [UIView animateWithDuration:0.3f animations:^{
                    _thumbnailAlbum.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    }
                }];
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *metadata = [self metadataForImage:processedImage withCLLocation:_currentLocation];
                
                // 仅此方法可以保存GPS信息。其他都不行。
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageToSavedPhotosAlbum:[processedImage CGImage] metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                    NSLog(@"ok");
                }];
            });
            
            
//            [self saveImageToCameraRoll:processedImage location:_currentLocation];
            
            
//            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:processedImage];
//                request.location = _currentLocation;
//                request.creationDate = [NSDate date];
//            } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                
//            }];
            
            
//            [self dismissViewControllerAnimated:YES completion:^{
//                
//                if (_delegate && [_delegate respondsToSelector:@selector(CSCameraViewControllerDelegateDoneWithImage:)]) {
//                    [_delegate CSCameraViewControllerDelegateDoneWithImage:processedImage];
//                }
//                
//            }];
        }
    }];
}

- (NSData *)writeMetadataIntoImageData:(NSData *)imageData metadata:(NSMutableDictionary *)metadata {
    // create an imagesourceref
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    
    // this is the type of image (e.g., public.jpeg)
    CFStringRef UTI = CGImageSourceGetType(source);
    
    // create a new data object and write the new image into it
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    if (!destination) {
        NSLog(@"Error: Could not create image destination");
    }
    // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) metadata);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    if (!success) {
        NSLog(@"Error: Could not create data from image destination");
    }
    CFRelease(destination);
    CFRelease(source);
    return dest_data;
}

- (NSData *)taggedImageData:(NSData *)imageData metadata:(NSDictionary *)metadata orientation:(UIImageOrientation)orientation {
    NSMutableDictionary *newMetadata = [NSMutableDictionary dictionaryWithDictionary:metadata];
    if (!newMetadata[(NSString *)kCGImagePropertyGPSDictionary] && _currentLocation) {
        newMetadata[(NSString *)kCGImagePropertyGPSDictionary] = [_currentLocation GPSDictionary];
    }
    
    // Reference: http://sylvana.net/jpegcrop/exif_orientation.html
    int newOrientation;
    switch (orientation) {
        case UIImageOrientationUp:
            newOrientation = 1;
            break;
            
        case UIImageOrientationDown:
            newOrientation = 3;
            break;
            
        case UIImageOrientationLeft:
            newOrientation = 8;
            break;
            
        case UIImageOrientationRight:
            newOrientation = 6;
            break;
            
        case UIImageOrientationUpMirrored:
            newOrientation = 2;
            break;
            
        case UIImageOrientationDownMirrored:
            newOrientation = 4;
            break;
            
        case UIImageOrientationLeftMirrored:
            newOrientation = 5;
            break;
            
        case UIImageOrientationRightMirrored:
            newOrientation = 7;
            break;
            
        default:
            newOrientation = -1;
    }
    if (newOrientation != -1) {
        newMetadata[(NSString *)kCGImagePropertyOrientation] = @(newOrientation);
    }
    NSData *newImageData = [self writeMetadataIntoImageData:imageData metadata:newMetadata];
    return newImageData;
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
    cameraProportionType = CameraProportionType34;
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview:previewView atIndex:0];
    
    _maskViewCapture = [[UIView alloc] initWithFrame:previewView.bounds];
    [self.view insertSubview:_maskViewCapture aboveSubview:previewView];
    _maskViewCapture.backgroundColor = [UIColor blackColor];
    _maskViewCapture.hidden = YES;
    
    [self addFocusTapGesture];
    
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    stillCamera.delegate = self;
    
    // 此处曾因错误添加，导致闪屏
    // [stillCamera addTarget:previewView];
    
    CGPoint focusPoint = CGPointMake(0.5f, 0.5f);
    [stillCamera.inputCamera lockForConfiguration:nil];
    if (stillCamera.inputCamera.isFocusPointOfInterestSupported) {
        stillCamera.inputCamera.focusPointOfInterest = focusPoint;
        stillCamera.inputCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    }
    stillCamera.inputCamera.focusPointOfInterest = focusPoint;
    stillCamera.inputCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    [stillCamera.inputCamera unlockForConfiguration];
    
    
    // TODO: 不加滤镜, 如何获取图片？
    /*
    [stillCamera addTarget:previewView];
    [stillCamera startCameraCapture];
    */
    
    
    // 添加滤镜
    
    // GPUImageStillCamera (output) -> GPUImageFilter (input, output) -> GPUImageView (input)
    // GPUImagePicture (output)     —> GPUImageFilter (input, output) —> GPUImageView (input)
    
    
    // TODO: 有时候使用LUT的滤镜没有效果。原因未知。
    // filter = [[GPUImageSepiaFilter alloc] init];
    filter = [[GPUImageToonFilter alloc] init];
    
    [filter addTarget:previewView];
    
    [stillCamera addTarget:filter];
    
    
    
    /*
    GPUImageFilter *filter1 = [[GPUImageToonFilter alloc] init];
    
    filter = [[GPUImageMoonlightFilter alloc] init];
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    
    // 每个filter之间要连接起来
    [filter addTarget:filter1];
    // 正确设置initialFilters和terminalFilter
    _filterGroup.initialFilters = @[filter];
    _filterGroup.terminalFilter = filter1;
    
    [_filterGroup addTarget:previewView];
    
    [stillCamera addTarget:_filterGroup];
    
    [stillCamera startCameraCapture];
     */
    
    
    /*
    GPUImageFilter *filter1 = [[GPUImageToonFilter alloc] init];
    GPUImageMoonlightFilter *filter2 = [[GPUImageMoonlightFilter alloc] init];
    NSArray *filterArr = @[filter2, filter1];
    _filterPipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filterArr input:stillCamera output:previewView];
    
    [stillCamera startCameraCapture];
     */
}

- (void)initExposureSlider {
    csSlider = [[CSSlider alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    csSlider.center = CGPointMake(CGRectGetWidth(self.view.frame) - 40, self.view.center.y);
    csSlider.value = 0.5f;
    [self.view addSubview:csSlider];
    csSlider.delegate = self;
    //    csSlider.thumbTintColor = [UIColor greenColor];
    
    csSlider.csThumbImage = [UIImage imageNamed:@"CSSliderHandler"];
    csSlider.csMinimumTrackTintColor = [UIColor redColor];
    csSlider.csMaximumTrackTintColor = [UIColor lightGrayColor];
    // Please use CSSliderTrackTintType_Divide after csMinimumTrackTintColor and csMaximumTrackTintColor set already. Please do not set minimumValueImage and maximumValueImage.
    csSlider.trackTintType = CSSliderTrackTintType_Linear;
    
        csSlider.sliderDirection = CSSliderDirection_Vertical;
}

#pragma mark - CSSliderDelegate

- (void)CSSliderValueChanged:(CSSlider *)sender {
    CGFloat bias = -1.5f + sender.value * (1.5f - (-1.5f));
    NSLog(@"%f", bias);
    [stillCamera.inputCamera lockForConfiguration:nil];
    [stillCamera.inputCamera setExposureTargetBias:bias completionHandler:nil];
    [stillCamera.inputCamera unlockForConfiguration];
}

- (void)CSSliderTouchDown:(CSSlider *)sender {
    
}

- (void)CSSliderTouchUp:(CSSlider *)sender {
    
}

- (void)CSSliderTouchCancel:(CSSlider *)sender {
    
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

#pragma mark - Focus tap

- (void)addFocusTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionFocus:)];
    [previewView addGestureRecognizer:tapGesture];
}

- (void)actionFocus:(UITapGestureRecognizer *)sender {
    if (!cameraFocusView) {
        cameraFocusView = [[CameraFocusView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.view addSubview:cameraFocusView];
    }
    
    CGPoint touchpoint = [sender locationInView:previewView];
    
    cameraFocusView.center = touchpoint;
    
    [cameraFocusView beginAnimation];
    
    // 需要同时设置focusMode为AVCaptureFocusModeAutoFocus
    NSLog(@"touchpoint : %@", NSStringFromCGPoint(touchpoint));
    // 需要坐标系转换
    CGPoint focusPoint = [self realFocusPoint:touchpoint];
    
    [stillCamera.inputCamera lockForConfiguration:nil];
    
    if (stillCamera.inputCamera.isFocusPointOfInterestSupported) {
        stillCamera.inputCamera.focusPointOfInterest = focusPoint;
        stillCamera.inputCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    }
    
    stillCamera.inputCamera.exposurePointOfInterest = focusPoint;
    stillCamera.inputCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    [stillCamera.inputCamera unlockForConfiguration];
}

- (CGPoint)realFocusPoint:(CGPoint)point
{
    CGPoint realPoint = CGPointZero;
    if (stillCamera.isBackFacingCameraPresent) {
        realPoint = CGPointMake(point.y / previewView.frame.size.height,
                                1 - point.x / previewView.frame.size.width);
    } else {
        realPoint = CGPointMake(point.y / previewView.frame.size.height,
                                point.x / previewView.frame.size.width);
    }
    return realPoint;
}

#pragma mark - 自动曝光调节

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

#pragma mark - 地理定位

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count > 0) {
        _currentLocation = [locations firstObject];
        
        [_locationManager stopUpdatingHeading];
    }
}

@end
