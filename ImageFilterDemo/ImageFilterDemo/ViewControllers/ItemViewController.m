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
#import <Photos/Photos.h>

#import "GPUImage.h"
#import "CPUImageFilterUtil.h"

#import "CameraViewController.h"
#import "VideoViewController.h"

#import "DemoGPUImageCameraViewController.h"
#import "DemoGPUImageVideoCameraViewController.h"

#import "CSAlbumViewController.h"

#import "CSAlbumCoverCollectionViewController.h"

#import "GPUImageMoonlightFilter.h"

#import "CSPreviewViewController.h"

#import "ViewImageCrop.h"
#import "MainViewController.h"

typedef NS_ENUM(NSInteger, enumDemoImageFilter) {
    demoCPUImageFilter = 0,
    demoCoreImageFilter,
    demoCoreImageFilterMultiple,
    demoGLKCoreImageFilter,
    
    demoGPUImageSepiaFilter,
    demoGPUImageCustomFilter,
    demoGPUImageFilterMaker,
    
    demoGPUImageBrightnessFilter,
    demoGPUImageFilterGroup,
    demoGPUImageFilterPipeline,
    
    demoGPUImageAlphaBlend,
    
    demoGPUImageStillCamera,
    demoGPUImageVideoCamera,
    
    demoSimpleAlbum,
    demoCustomAlbum,
    
    demoCustomPreview,
    
    demoSimpleCamera,
    demoCustomCamera,
    
    demoSimpleVideo,
    demoCustomVideo,
    
    demoImageCrop,
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
    
    GPUImageFilterPipeline *filterPipeline;
    
    GPUImageBrightnessFilter *brightnessFilter;
    
    GPUImagePicture *gpuImagePic;
    GPUImageView *gpuImageView;
    
    ViewImageCrop *_viewImageCrop;
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
                              @"GPUImage Filter Maker",
                              @"GPUImage Brightness Filter",
                              @"GPUImage Filter Group",
                              @"GPUImage Filter Pipeline",
                              
                              @"GPUImage Alpha Blend",
                              
                              @"GPUImage Still Camera",
                              @"GPUImage Video Camera",
                              
                              @"Simple Album",
                              @"Custom Album",
                              
                              @"Custom Preview",
                              
                              @"Simple Camera",
                              @"Custom Camera",
                              
                              @"Simple Video",
                              @"Custom Video",
                              
                              @"Image Crop",
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
    
    gpuImageView = [[GPUImageView alloc] initWithFrame:_filteredImageView.frame];
    [self.view addSubview:gpuImageView];
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
        
        case demoGPUImageFilterMaker:
            [self demoGPUImageFilterMaker];
            break;
            
        case demoGPUImageBrightnessFilter:
            [self demoGPUImageBrightnessFilter];
            break;
        case demoGPUImageFilterGroup:
            [self demoGPUImageFilterGroup];
            break;
        case demoGPUImageFilterPipeline:
            [self demoGPUImageFilterPipeline];
            break;
            
        case demoGPUImageAlphaBlend:
            [self demoGPUImageAlphaBlend];
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
            [self demoCustomAlbum];
            break;
            
        case demoCustomPreview:
            [self demoCustomPreview];
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
            
        case demoImageCrop:
            [self demoImageCrop];
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
    
    
    /*
    GPUImageSepiaFilter *gpuSepiaFilter = [[GPUImageSepiaFilter alloc] init];
    [gpuSepiaFilter useNextFrameForImageCapture];
    
    GPUImagePicture *gpuImagePicture = [[GPUImagePicture alloc] initWithImage:_originImage];
    [gpuImagePicture addTarget:gpuSepiaFilter]; // 添加滤镜
    
    [gpuImagePicture processImage]; // 开始渲染
    
    _filteredImage = [gpuSepiaFilter imageFromCurrentFramebuffer]; // 获取渲染结果图
    _filteredImageView.image = _filteredImage;
     */
    
    
    /*
    GPUImageSepiaFilter *gpuSepiaFilter = [[GPUImageSepiaFilter alloc] init];
    [gpuSepiaFilter useNextFrameForImageCapture];
    
    // 直接将渲染结果图输出至GPUImageView中，就不需要取图了。但是左右会有黑框。TODO：原因不明。
    [gpuSepiaFilter addTarget:gpuImageView];
    
    GPUImagePicture *gpuImagePicture = [[GPUImagePicture alloc] initWithImage:_originImage];
    [gpuImagePicture addTarget:gpuSepiaFilter]; // 添加滤镜
    
    [gpuImagePicture processImage]; // 开始渲染
     */
}

- (void)demoGPUImageCustomFilter {
    [self displayOriginImage:nil];
    
    GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"GPUImageCustomFilter"];
    _filteredImage = [customFilter imageByFilteringImage:_originImage];
    _filteredImageView.image = _filteredImage;
}

- (void)demoGPUImageFilterMaker {
    [self displayOriginImage:nil];
    
    
    // TODO: 第一次点击进去itemVC，滤镜并没有效果。再次进去即可。原因暂时不明！！！
    // 基准图：lookup_amatorka.png
    /*
    GPUImageAmatorkaFilter *lookupFilter = [[GPUImageAmatorkaFilter alloc] init];
    _filteredImage = [lookupFilter imageByFilteringImage:_originImage];
    _filteredImageView.image = _filteredImage;
    */
    
    
    // 根据LUT，封装一个GPUImageMoonlightFilter
    
     GPUImageMoonlightFilter *lookupFilter = [[GPUImageMoonlightFilter alloc] init];
     _filteredImage = [lookupFilter imageByFilteringImage:_originImage];
     _filteredImageView.image = _filteredImage;
     
    
    
    // 自己制作的基准图: LUT_Bleach.png, LUT_Moonlight.png, LUT_From_PS_ATN_File.png
    /*
    GPUImagePicture *originalImageSource = [[GPUImagePicture alloc] initWithImage:_originImage];
    
    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"LUT_Moonlight.png"]];
    
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    
    [originalImageSource addTarget:lookupFilter];
    [lookupImageSource addTarget:lookupFilter];
    
    [lookupFilter useNextFrameForImageCapture];
    [originalImageSource processImage];
    [lookupImageSource processImage];
    
    _filteredImage = [lookupFilter imageFromCurrentFramebuffer];
    _filteredImageView.image = _filteredImage;
    */
    
    
    // 自己使用ToneCurve acv文件
    /*
    GPUImageToneCurveFilter *curveFilter = [[GPUImageToneCurveFilter alloc] initWithACV:@"customToneCurve"];
    _filteredImage = [curveFilter imageByFilteringImage:_originImage];
    _filteredImageView.image = _filteredImage;
    */
    
    
    // 添加texture, 使用GPUImageTwoInputFilter来制作filter.
    /*
//    GPUImageColorBurnBlendFilter *blendFilter = [[GPUImageColorBurnBlendFilter alloc] init];
//    GPUImageLinearBurnBlendFilter *blendFilter = [[GPUImageLinearBurnBlendFilter alloc] init];
//    GPUImageMultiplyBlendFilter *blendFilter = [[GPUImageMultiplyBlendFilter alloc] init];
//    GPUImageNormalBlendFilter *blendFilter = [[GPUImageNormalBlendFilter alloc] init];
//    GPUImageOverlayBlendFilter *blendFilter = [[GPUImageOverlayBlendFilter alloc] init];
    GPUImageScreenBlendFilter *blendFilter = [[GPUImageScreenBlendFilter alloc] init];
    
    [blendFilter useNextFrameForImageCapture];
    
    GPUImagePicture *originalImageSource = [[GPUImagePicture alloc] initWithImage:_originImage];

//    GPUImagePicture *textureImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture_colorBurnBlend_1.png"]];
//    GPUImagePicture *textureImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture_linearBurnBlend_1.png"]];
//    GPUImagePicture *textureImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture_multiplyBlend_1.png"]];
//    GPUImagePicture *textureImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture_normalBlend_1.png"]];
//    GPUImagePicture *textureImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture_overlayBlend_1.png"]];
    GPUImagePicture *textureImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture_screenBlend_1.png"]];

    
    [originalImageSource addTarget:blendFilter];
    [originalImageSource processImage];
    
    [textureImageSource addTarget:blendFilter];
    [textureImageSource processImage];
    
    _filteredImage = [blendFilter imageFromCurrentFramebuffer];
    _filteredImageView.image = _filteredImage;
     */
}

- (void)demoGPUImageBrightnessFilter {
    [self displayOriginImage:nil];
    
    [self addBrightnessSlider];
    
    brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    brightnessFilter.brightness = 0.0;
    
    _filteredImage = [brightnessFilter imageByFilteringImage:_originImage];
    _filteredImageView.image = _filteredImage;
}

- (void)addBrightnessSlider {
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    [self.view addSubview:slider];
    slider.center = _originImageView.center;
    slider.minimumValue = -0.5f;
    slider.maximumValue = 0.5f;
    
    [slider addTarget:self action:@selector(actionBrightnessSlider:) forControlEvents:UIControlEventValueChanged];
}

- (void)actionBrightnessSlider:(UISlider *)sender {
    brightnessFilter.brightness = sender.value;
    
    [[filterPipeline.filters lastObject] useNextFrameForImageCapture];
    [gpuImagePic processImage];
    
    _filteredImage = [filterPipeline currentFilteredFrame];
    _filteredImageView.image = _filteredImage;

    // 频繁滑动slider，会导致crash。原因未知。
    // arc环境下，只负责回收oc对象的内存，显存自然需要GPUImage使用者自己来回收
//    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
}

- (void)demoGPUImageFilterGroup {
    [self displayOriginImage:nil];
    
    [self addBrightnessSlider];
    
    /*
     GPUImagePicture *gpuImagePic = [[GPUImagePicture alloc] initWithImage:_originImage];
     
     GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];
     
     GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
     [filterGroup addFilter:sepiaFilter];
     
     brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
     brightnessFilter.brightness = 0.5;
     [filterGroup addFilter:brightnessFilter];
     
     [sepiaFilter addTarget:brightnessFilter];
     
     filterGroup.initialFilters = @[sepiaFilter, brightnessFilter];
     filterGroup.terminalFilter = sepiaFilter;
     
     //    [gpuImagePic addTarget:filterGroup];
     //    [filterGroup useNextFrameForImageCapture];
     //    [gpuImagePic processImage];
     
     _filteredImage = [filterGroup imageFromCurrentFramebuffer];
     _filteredImageView.image = _filteredImage;
     */
}

- (void)demoGPUImageFilterPipeline {
    [self displayOriginImage:nil];
    
    [self addBrightnessSlider];
    
    
    gpuImagePic = [[GPUImagePicture alloc] initWithImage:_originImage];
    
    GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"GPUImageCustomFilter"];
    // 使用LUT的滤镜，亮度调节无效。原因未知。
//    GPUImageMoonlightFilter *lookupFilter = [[GPUImageMoonlightFilter alloc] init];
    
    brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    brightnessFilter.brightness = 0.0;
    
    NSArray *filters = @[brightnessFilter, customFilter];
    filterPipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filters input:gpuImagePic output:gpuImageView];
    
    // useNextFrameForImageCapture与processImage一般成对出现。
    [[filterPipeline.filters lastObject] useNextFrameForImageCapture];
    [gpuImagePic processImage];
    
    gpuImageView.hidden = YES;
    
    // filteredImage为nil。原因在于：
    // [filterPipeline currentFilteredFrame] 调用最后一个filter的imageFromCurrentFramebuffer方法。
    // 所以需要提前对最后一个filter调用useNextFrameForImageCapture方法，image才能放到framebuffer中。
    _filteredImage = [filterPipeline currentFilteredFrame];
    _filteredImageView.image = _filteredImage;
}

#pragma mark - GPUImage blend

- (void)demoGPUImageAlphaBlend
{
    [self displayOriginImage:nil];
    
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.f;
    
    
    /*
    // GPUImagePicture+GPUImagePicture
    UIImage *image = [UIImage imageNamed:@"Model.png"];
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    
    UIImage *image2 = [UIImage imageNamed:@"66.jpg"];
    GPUImagePicture *picture2 = [[GPUImagePicture alloc] initWithImage:image2];
    
    // 最后一个addTarget至filter的视为主输出。
    // 因此，如果mix为1，则输出为picture2
    [picture addTarget:blendFilter];
    [picture2 addTarget:blendFilter];
    
    [blendFilter useNextFrameForImageCapture];
    
    [picture processImage];
    [picture2 processImage];
     
    _filteredImage = [blendFilter imageFromCurrentFramebuffer];
    */
    
    /*
    // GPUImagePicture+GPUImageUIElement
    UIImage *image = [UIImage imageNamed:@"Model.png"];
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    
    UIView *view = [[UIView alloc] initWithFrame:_filteredImageView.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.text = @"水印";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:30.f];
    [view addSubview:label];
    label.center = view.center;

    GPUImageUIElement *uiElement = [[GPUImageUIElement alloc] initWithView:view];
    
    [picture addTarget:blendFilter];
    [uiElement addTarget:blendFilter];
    
    [blendFilter useNextFrameForImageCapture];
    
    [picture processImage];
    [uiElement update]; // 不能少
    
    _filteredImage = [blendFilter imageFromCurrentFramebuffer];
    */
    
    
    
    // CoreGraphics
    UIView *view = [[UIView alloc] initWithFrame:_filteredImageView.bounds];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:view.bounds];
    imageview.image = [UIImage imageNamed:@"Model.png"];
    [view addSubview:imageview];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    iconView.image = [UIImage imageNamed:@"btnFilter"];
    [view addSubview:iconView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.text = @"水印";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:30.f];
    [view addSubview:label];
    label.center = view.center;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    _filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _filteredImageView.image = _filteredImage;
}

#pragma mark - GPUImage Still Camera

- (void)demoGPUImageStillCamera {
//    DemoGPUImageCameraViewController *camera = [[DemoGPUImageCameraViewController alloc] init];
//    [self presentViewController:camera animated:YES completion:nil];
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    [self presentViewController:mainVC animated:YES completion:nil];
    
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
    CSAlbumViewController *albumVC = [[CSAlbumViewController alloc] init];
//    CSAlbumCoverCollectionViewController *albumVC = [[CSAlbumCoverCollectionViewController alloc] init];
    
    [self presentViewController:albumVC animated:YES completion:nil];
}

#pragma mark - Custom Preview

- (void)demoCustomPreview {
    CSPreviewViewController *previewVC = [[CSPreviewViewController alloc] init];
    [self presentViewController:previewVC animated:YES completion:nil];
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
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
        if (assets.count > 0) {
            PHAsset *asset = [assets firstObject];
            
            NSLog(@"%@", asset.creationDate);
            NSLog(@"%@", asset.location);
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                NSLog(@"get asset image");
                
            }];
        }
        
    }
    
    
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

#pragma mark - image crop

- (void)demoImageCrop
{
    CGFloat heightCrop = 150 * [UIScreen mainScreen].scale;
    _viewImageCrop = [[ViewImageCrop alloc] initWithFrame:CGRectMake(0, 0, kCSScreenWidth, heightCrop)];
    [self.view addSubview:_viewImageCrop];
    _viewImageCrop.image = [UIImage imageNamed:@"Shiny_2.jpg"];
    _viewImageCrop.center = self.view.center;
    
    UIButton *btnCrop = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 50, kCSScreenWidth, 30)];
    [btnCrop setTitle:@"Crop" forState:UIControlStateNormal];
    [btnCrop setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:btnCrop];
    [btnCrop addTarget:self action:@selector(actionBtnImageCrop:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)actionBtnImageCrop:(UIButton *)sender
{
    UIImage *ret = _viewImageCrop.imageCropped;
    NSLog(@"123");
}

@end
