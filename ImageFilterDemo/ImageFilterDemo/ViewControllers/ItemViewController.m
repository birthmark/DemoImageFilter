//
//  ItemViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 15/8/30.
//  Copyright (c) 2015年 icetime17. All rights reserved.
//

#import "ItemViewController.h"

#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GPUImage.h"
#import "CPUImageFilterUtil.h"

#import "CameraViewController.h"
#import "VideoViewController.h"

#import "DemoGPUImageCameraViewController.h"
#import "DemoGPUImageVideoCameraViewController.h"

typedef NS_ENUM(NSInteger, enumDemoImageFilter) {
    demoCPUImageFilter = 0,
    demoCoreImageFilter,
    demoCoreImageFilterMultiple,
    demoGLKCoreImageFilter,
    
    demoGPUImageSepiaFilter,
    demoGPUImageCustomFilter,
    demoGPUImageStillCamera,
    demoGPUImageVideoCamera,
    
    demoSimpleAlbum,
    demoCustomAlbum,
    demoSimpleCamera,
    demoCustomCamera,
    demoSimpleVideo,
    demoCustomVideo,
};

@interface ItemViewController () <

    UIGestureRecognizerDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
>

@property (nonatomic) NSArray *demosImageFilter;

@property (nonatomic) UILabel *lbOriginalImage;
@property (nonatomic) UILabel *lbProcessedImage;

@property (nonatomic) UIImage *originImage;
@property (nonatomic) UIImageView *originImageView;

@property (nonatomic) UIImage *filteredImage;
@property (nonatomic) UIImageView *filteredImageView;


@property (nonatomic) EAGLContext *eaglContext;
@property (nonatomic) CIContext *ciContext;
@property (nonatomic) CIFilter *ciFilter;
@property (nonatomic) CIImage *ciImage;
@property (nonatomic) GLKView *glkView;

@end

@implementation ItemViewController
{
    // GPUImageStillCamera要放在成员变量或属性中. 否则GPUImageView显示空白.
    GPUImageStillCamera *stillCamera;
    GPUImageVideoCamera *videoCamera;
    GPUImageMovieWriter *movieWriter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.demosImageFilter = @[
                              @"CPU Image Filter",
                              @"CoreImage Filter",
                              @"CoreImage Filter Multiple",
                              @"GLKView and CoreImage Filter",
                              @"GPUImage Sepia Filter",
                              @"GPUImage Custom Filter",
                              @"GPUImage Still Camera",
                              @"GPUImage Video Camera",
                              @"Simple Album",
                              @"Custom Album",
                              @"Simple Camera",
                              @"Custom Camera",
                              @"Simple Video",
                              @"Custom Video",
                              ];
    [self demosFilter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = self.item;
}

#pragma mark - display origin image

- (void)displayOriginImage:(UIImage *)image {
    _lbOriginalImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 30)];
    _lbOriginalImage.text = @"Original image...";
    _lbOriginalImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lbOriginalImage];
    
    _originImage = image ? image : [UIImage imageNamed:@"Model"];
    _originImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150) / 2, 100, 150, 200)];
    _originImageView.image = _originImage;
    [self.view addSubview:_originImageView];
    
    _lbProcessedImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, self.view.frame.size.width - 20, 30)];
    _lbProcessedImage.text = @"Processed image...";
    _lbProcessedImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lbProcessedImage];
    
    _filteredImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150) / 2, 340, 150, 200)];
    [self.view addSubview:_filteredImageView];
}

- (void)demosFilter {
    switch ([self.demosImageFilter indexOfObject:self.item]) {
        case demoCPUImageFilter:
            [self demoCPUImageFilter];
            break;
        case demoCoreImageFilter:
            [self demoCoreImageFilter];
            break;
        case demoCoreImageFilterMultiple:
            [self demoCoreImageFilterMultiple];
            break;
        case demoGLKCoreImageFilter:
            [self demoGLKCoreImageFilter];
            break;
            
        case demoGPUImageSepiaFilter:
            [self demoGPUImageSepiaFilter];
            break;
        case demoGPUImageCustomFilter:
            [self demoGPUImageCustomFilter];
            break;
        case demoGPUImageStillCamera:
            [self demoGPUImageStillCamera];
            break;
        case demoGPUImageVideoCamera:
            [self demoGPUImageVideoCamera];
            break;
            
        case demoSimpleAlbum:
            [self demoSimpleAlbum];
            break;
        case demoCustomAlbum:
            
            break;
        case demoSimpleCamera:
            [self demoSimpleCamera];
            break;
        case demoCustomCamera:
            [self demoCustomCamera];
            break;
        case demoSimpleVideo:
            [self demoSimpleVideo];
            break;
        case demoCustomVideo:
            [self demoCustomVideo];
            break;
        default:
            break;
    }
}

#pragma mark - CPU Image Filter

- (void)demoCPUImageFilter {
    [self displayOriginImage:nil];
    
    UIScrollView *scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 80, self.view.frame.size.width - 20, 80)];
    scrollerView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollerView.showsHorizontalScrollIndicator = NO;
    scrollerView.showsVerticalScrollIndicator = NO;
    scrollerView.bounces = NO;
    [self.view addSubview:scrollerView];
    
    NSArray *filters = [NSArray arrayWithObjects:
                        @"原图",@"LOMO",@"黑白",@"复古",@"哥特",
                        @"锐色",@"淡雅",@"酒红",@"青柠",@"浪漫",
                        @"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    CGFloat x = 0;
    for(NSInteger i=0; i<filters.count; i++)
    {
        x = 10 + 50*i;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCPUImageFilterStyle:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        recognizer.delegate = self;
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, 40, 40)];
        [bgImageView setTag:i];
        [bgImageView addGestureRecognizer:recognizer];
        [bgImageView setUserInteractionEnabled:YES];
        bgImageView.image = [self cpuImageFilteredImage:_originImage filterIndex:i];
        [scrollerView addSubview:bgImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 50, 40, 20)];
        [label setText:[filters objectAtIndex:i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [label setTextColor:[UIColor blackColor]];
        [label setUserInteractionEnabled:NO];
        [scrollerView addSubview:label];
    }
    scrollerView.contentSize = CGSizeMake(x + 50, 80);
    
    [self setCPUImageFilter:_originImage filterIndex:0];
}

- (IBAction)chooseCPUImageFilterStyle:(UITapGestureRecognizer *)sender {
    [self setCPUImageFilter:_originImage filterIndex:sender.view.tag];
}

- (void)setCPUImageFilter:(UIImage *)image filterIndex:(NSInteger)index {
    _filteredImage = [self cpuImageFilteredImage:image filterIndex:index];
    _filteredImageView.image = _filteredImage;
}

- (UIImage *)cpuImageFilteredImage:(UIImage *)image filterIndex:(NSInteger)index {
    UIImage *retImage;
    const float *colorMatrix = NULL;
    NSString *filterKey = @"";
    switch (index) {
        case 0:
            filterKey = @"origin";
            return image;
            break;
        case 1:
            colorMatrix = colormatrix_lomo;
            filterKey = @"lomo";
            break;
        case 2:
            colorMatrix = colormatrix_heibai;
            filterKey = @"heibai";
            break;
        case 3:
            colorMatrix = colormatrix_huajiu;
            filterKey = @"huajiu";
            break;
        case 4:
            colorMatrix = colormatrix_gete;
            filterKey = @"gete";
            break;
        case 5:
            colorMatrix = colormatrix_ruise;
            filterKey = @"ruise";
            break;
        case 6:
            colorMatrix = colormatrix_danya;
            filterKey = @"danya";
            break;
        case 7:
            colorMatrix = colormatrix_jiuhong;
            filterKey = @"jiuhong";
            break;
        case 8:
            colorMatrix = colormatrix_qingning;
            filterKey = @"qingning";
            break;
        case 9:
            colorMatrix = colormatrix_langman;
            filterKey = @"langman";
            break;
        case 10:
            colorMatrix = colormatrix_guangyun;
            filterKey = @"guangyun";
            break;
        case 11:
            colorMatrix = colormatrix_landiao;
            filterKey = @"landiao";
            break;
        case 12:
            colorMatrix = colormatrix_menghuan;
            filterKey = @"menghuan";
            break;
        case 13:
            colorMatrix = colormatrix_yese;
            filterKey = @"yese";
            break;
        default:
            filterKey = @"origin";
            break;
    }
    
    retImage = [CPUImageFilterUtil imageWithImage:image withColorMatrix:colorMatrix];
    return retImage;
}

#pragma mark - Core Image Filter

- (void)demoCoreImageFilter {
    [self displayOriginImage:nil];
    
    // 导入CIImage
    CIImage *ciInputImage = [[CIImage alloc] initWithImage:self.originImage];
    
    // 创建CIFilter
    CIFilter *filterPixellate = [CIFilter filterWithName:@"CIPixellate"];
    [filterPixellate setValue:ciInputImage forKey:kCIInputImageKey];
    [filterPixellate setDefaults];
    NSLog(@"filterPixellate : %@", filterPixellate.attributes);

    // 获取滤镜效果之后的CIImage
    CIImage *ciOutputImagePixellate = [filterPixellate valueForKey:kCIOutputImageKey];
    
    // 使用CIContext将CI中的图片渲染出来为CGImageRef
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciOutputImagePixellate fromRect:[ciOutputImagePixellate extent]];
    
    // 获取UIImage
    _filteredImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    _filteredImageView.image = _filteredImage;
}

- (void)demoCoreImageFilterMultiple {
    [self displayOriginImage:nil];
    
    // 导入CIImage
    CIImage *ciInputImage = [[CIImage alloc] initWithImage:self.originImage];
    
    // 创建CIFilter
    CIFilter *filterPixellate = [CIFilter filterWithName:@"CIPixellate"];
    [filterPixellate setValue:ciInputImage forKey:kCIInputImageKey];
    [filterPixellate setDefaults];
    NSLog(@"filterPixellate : %@", filterPixellate.attributes);
    
    // 获取滤镜效果之后的CIImage
    CIImage *ciOutputImagePixellate = (CIImage *)[filterPixellate valueForKey:kCIOutputImageKey];
    
    // 滤镜可以叠加, 上一个滤镜的输出作为下一个滤镜的输入
    CIFilter *filterSepiaTone = [CIFilter filterWithName:@"CISepiaTone"];
    [filterSepiaTone setValue:ciOutputImagePixellate forKey:kCIInputImageKey];
    [filterSepiaTone setDefaults];
    NSLog(@"filterSepiaTone : %@", filterSepiaTone.attributes);
    
    CIImage *ciOutputImageSepiaTone = [filterSepiaTone outputImage];
    
    // 使用CIContext将CI中的图片渲染出来为CGImageRef
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciOutputImageSepiaTone fromRect:[ciOutputImageSepiaTone extent]];
    
    // 获取UIImage
    _filteredImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    _filteredImageView.image = _filteredImage;
}

#pragma mark - GLKView and CoreImage Filter

- (void)demoGLKCoreImageFilter {
    [self displayOriginImage:nil];
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_eaglContext];
    
    // 创建GLKView, 要调用bindDrawable和display. 类似viewPort.
    _glkView = [[GLKView alloc] initWithFrame:_filteredImageView.frame context:_eaglContext];
    [_glkView bindDrawable];
    [self.view addSubview:_glkView];
    
    // 创建CIContext
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace:[NSNull null]}];
    
    // CoreImage设置
    _ciImage = [[CIImage alloc] initWithImage:_originImage];
    _ciFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [_ciFilter setValue:_ciImage forKey:kCIInputImageKey];
    [_ciFilter setValue:@(0) forKey:kCIInputIntensityKey];
    
    // 开始渲染
    [_ciContext drawImage:[_ciFilter outputImage] inRect:CGRectMake(0, 0, _glkView.drawableWidth, _glkView.drawableHeight) fromRect:[_ciImage extent]];
    [_glkView display];
    
    _lbProcessedImage.text = @"Slide to change the filter effect...";
    // 使用UISlider进行动态渲染
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 50, self.view.frame.size.width - 20, 64)];
    slider.minimumValue = 0.0f;
    slider.maximumValue = 5.0f;
    [slider addTarget:self action:@selector(glkSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}

- (void)glkSliderValueChanged:(UISlider *)sender {
    [_ciFilter setValue:_ciImage forKey:kCIInputImageKey];
    [_ciFilter setValue:@(sender.value) forKey:kCIInputIntensityKey];
    
    [_glkView deleteDrawable];
    [_glkView bindDrawable];
    [_ciContext drawImage:[_ciFilter outputImage] inRect:CGRectMake(0, 0, _glkView.drawableWidth, _glkView.drawableHeight) fromRect:[_ciImage extent]];
    [_glkView display];
}

#pragma mark - GPUImage Filter

- (void)demoGPUImageSepiaFilter {
    [self displayOriginImage:nil];

    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    _filteredImage = [filter imageByFilteringImage:_originImage];
    _filteredImageView.image = _filteredImage;
    
//    GPUImagePicture *gpuImagePic = [[GPUImagePicture alloc] initWithImage:_originImage];
//    GPUImageSepiaFilter *gpuSepiaFilter = [[GPUImageSepiaFilter alloc] init];
//    [gpuImagePic addTarget:gpuSepiaFilter];
//    [gpuImagePic useNextFrameForImageCapture];
//    [gpuImagePic processImage];
//    _filteredImage = [gpuSepiaFilter imageFromCurrentFramebuffer];
//    _filteredImageView.image = _filteredImage;
}

- (void)demoGPUImageCustomFilter {
    [self displayOriginImage:nil];
    
    GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"GPUImageCustomFilter"];
    _filteredImage = [customFilter imageByFilteringImage:_originImage];
    _filteredImageView.image = _filteredImage;
}

#pragma mark - GPUImage Still Camera

- (void)demoGPUImageStillCamera {
    DemoGPUImageCameraViewController *camera = [[DemoGPUImageCameraViewController alloc] init];
    [self presentViewController:camera animated:YES completion:nil];
    
    return;
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageSepiaFilter *sepiafilter = [[GPUImageSepiaFilter alloc] init];
    [stillCamera addTarget:sepiafilter];
    
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:filterView];
    
    [sepiafilter addTarget:filterView];
    
//    [stillCamera addTarget:filterView];

    [stillCamera startCameraCapture];
}

#pragma mark - GPUImage Video Camera

- (void)demoGPUImageVideoCamera {
    DemoGPUImageVideoCameraViewController *videoVC = [[DemoGPUImageVideoCameraViewController alloc] init];
    [self presentViewController:videoVC animated:YES completion:nil];
    
    return;
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    GPUImageEmbossFilter *filter = [[GPUImageEmbossFilter alloc] init];
    [videoCamera addTarget:filter];
    
    // GPUImageView *filterView = (GPUImageView *)self.view;
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:filterView];
    [filter addTarget:filterView];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingString:@"/Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480, 640)];
    movieWriter.encodingLiveVideo = YES;
    [filter addTarget:movieWriter];
    
    [videoCamera startCameraCapture];

    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^{
        NSLog(@"Start recording...");
        videoCamera.audioEncodingTarget = movieWriter;
        movieWriter.shouldPassthroughAudio = YES;
        [movieWriter startRecording];
        
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^{
            [filter removeTarget:movieWriter];
            videoCamera.audioEncodingTarget = nil;
            [movieWriter finishRecording];
            NSLog(@"Stop recording...");
        });
    });
}

#pragma mark - Simple Album Demo

- (void)demoSimpleAlbum {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Custom Album Demo

- (void)demoCustomAlbum {

}

#pragma mark - Simple Camera Demo

- (void)demoSimpleCamera {
    CameraViewController *camera = [[CameraViewController alloc] init];
    [self presentViewController:camera animated:YES completion:nil];
}

#pragma mark - Custom Camera Demo

- (void)demoCustomCamera {
    
}

#pragma mark - Simple Video Demo

- (void)demoSimpleVideo {
    VideoViewController *video = [[VideoViewController alloc] init];
    [self presentViewController:video animated:YES completion:nil];
}

#pragma mark - Custom Video Demo

- (void)demoCustomVideo {

}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *editedImage = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage *savedImage = editedImage ? editedImage : originalImage;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(savedImage, nil, nil, nil); // 保存到系统相册
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self displayOriginImage:savedImage];
        [self displayAssetsLibraryCover];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Assets Library Operations

- (void)displayAssetsLibraryCover {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            UIImage *cover = [[UIImage alloc] initWithCGImage:[group posterImage]];
            self.lbProcessedImage.text = @"Cover of assets library...";
            self.filteredImage = cover;
            self.filteredImageView.image = self.filteredImage;
        }
    } failureBlock:^(NSError *error) {
        self.lbProcessedImage.text = @"Failed to get assets library...";
        NSLog(@"%@", self.lbProcessedImage.text);
        self.filteredImage = _originImage;
        self.filteredImageView.image = self.filteredImage;
    }];
}

@end
