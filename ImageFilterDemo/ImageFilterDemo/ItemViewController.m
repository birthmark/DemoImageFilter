//
//  ItemViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 15/8/30.
//  Copyright (c) 2015年 icetime17. All rights reserved.
//

#import "ItemViewController.h"
#import "CPUImageFilterUtil.h"
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, enumDemoImageFilter) {
    demoCPUImageFilter = 0,
    demoCoreImageFilter,
    demoCoreImageFilterMultiple,
    demoGLKCoreImageFilter,
};

@interface ItemViewController ()

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.demosImageFilter = @[@"CPU Image Filter", @"CoreImage Filter", @"CoreImage Filter Multiple", @"GLKView and CoreImage Filter"];
    [self demosFilter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = self.item;
}

#pragma mark - display origin image

- (void)displayOriginImage {
    _lbOriginalImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 30)];
    _lbOriginalImage.text = @"Original image...";
    _lbOriginalImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lbOriginalImage];
    
    _originImage = [UIImage imageNamed:@"testImage"];
    _originImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 200)];
    _originImageView.image = _originImage;
    [self.view addSubview:_originImageView];
    
    _lbProcessedImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, self.view.frame.size.width - 20, 30)];
    _lbProcessedImage.text = @"Processed image...";
    _lbProcessedImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lbProcessedImage];
    
    _filteredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 340, self.view.frame.size.width - 20, 200)];
    [self.view addSubview:_filteredImageView];
}

- (void)demosFilter {
    // self.demosImageFilter = @[@"CPU Image Filter", @"CoreImage Filter", @"CoreImage Filter Multiple", @"GLKView and CoreImage Filter"];
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
        default:
            break;
    }
}

#pragma mark - CPU Image Filter

- (void)demoCPUImageFilter {
    [self displayOriginImage];
    
    UIScrollView *scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 100, self.view.frame.size.width - 20, 80)];
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
    [self displayOriginImage];
    
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
    [self displayOriginImage];
    
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
    [self displayOriginImage];
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_eaglContext];
    
    // 创建GLKView, 要调用bindDrawable和display. 类似viewPort.
    _glkView = [[GLKView alloc] initWithFrame:CGRectMake(10, 340, self.view.frame.size.width - 20, 200) context:_eaglContext];
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
    
    [_ciContext drawImage:[_ciFilter outputImage] inRect:CGRectMake(0, 0, _glkView.drawableWidth, _glkView.drawableHeight) fromRect:[_ciImage extent]];
    [_glkView display];
}

@end
