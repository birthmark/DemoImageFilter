//
//  ItemViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 15/8/30.
//  Copyright (c) 2015年 icetime17. All rights reserved.
//

#import "ItemViewController.h"
#import "CPUImageFilterUtil.h"

typedef NS_ENUM(NSInteger, enumDemoImageFilter) {
    demoCPUImageFilter = 0,
    demoCoreImageFilter,
    demoCoreImageFilterMultiple,
};

@interface ItemViewController ()

@property (nonatomic) NSArray *demosImageFilter;

@property (nonatomic) UILabel *lbOriginalImage;
@property (nonatomic) UILabel *lbProcessedImage;

@property (nonatomic) UIImage *originImage;
@property (nonatomic) UIImageView *originImageView;

@property (nonatomic) UIImage *filteredImage;
@property (nonatomic) UIImageView *filteredImageView;

@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.demosImageFilter = @[@"CPU Image Filter", @"CoreImage Filter", @"CoreImage Filter Multiple"];
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
    // self.demosImageFilter = @[@"CPU Image Filter", @"CoreImage Filter", @"CoreImage Filter Multiple"];
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
        default:
            break;
    }
}

- (void)demoCPUImageFilter {
    [self displayOriginImage];
    
    NSArray *filters = [NSArray arrayWithObjects:
                    @"原图",@"LOMO",@"黑白",@"复古",@"哥特",
                    @"锐色",@"淡雅",@"酒红",@"青柠",@"浪漫",
                    @"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    
    const float *colorMatrix = NULL;
    NSString *cpuImageFilterKey = @"";
    
    colorMatrix = colormatrix_lomo;
    cpuImageFilterKey = @"lomo";
    
    _filteredImage = [CPUImageFilterUtil imageWithImage:_originImage withColorMatrix:colorMatrix];
    _filteredImageView.image = _filteredImage;
}

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

@end
