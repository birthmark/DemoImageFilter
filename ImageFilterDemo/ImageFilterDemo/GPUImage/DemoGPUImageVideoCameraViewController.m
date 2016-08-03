//
//  DemoGPUImageVideoCameraViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "DemoGPUImageVideoCameraViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CSVideoCameraViewController.h"

@interface DemoGPUImageVideoCameraViewController () <

    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    CSVideoCameraViewControllerDelegate
>

@end

@implementation DemoGPUImageVideoCameraViewController {

    UIImageView *imageView;
    
    UIButton *btnPlayVideo;
    
    NSString *recentVideoPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addBtnBack];
    
    [self addBtns];
    
    [self addUIImageView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addBtnBack{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 30)];
    [btn setTitle:@"Close" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addBtns {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 50)];
    [btn setTitle:@"Video" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionVideo:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
    
    btnPlayVideo = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    [btnPlayVideo setTitle:@"Play" forState:UIControlStateNormal];
    [btnPlayVideo setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnPlayVideo setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btnPlayVideo addTarget:self action:@selector(actionPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    btnPlayVideo.layer.borderColor = [UIColor redColor].CGColor;
    btnPlayVideo.layer.borderWidth = 2.0f;
    [self.view addSubview:btnPlayVideo];
    btnPlayVideo.hidden = YES;
}

- (void)actionVideo:(UIButton *)sender {
    CSVideoCameraViewController *cameraVC = [[CSVideoCameraViewController alloc] init];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}

- (void)actionPlayVideo:(UIButton *)sender {
    if (recentVideoPath) {
        NSURL *movieURL = [NSURL fileURLWithPath:recentVideoPath];
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
        player.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        player.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        
        [self presentMoviePlayerViewControllerAnimated:player];
    }
}

- (void)actionAlbum:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)addUIImageView {
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
}

#pragma mark - <CSVideoCameraViewControllerDelegate>

- (void)CSVideoCameraViewControllerDelegateDoneWithVideoPath:(NSString *)videoPath {
    recentVideoPath = videoPath;
    
    if (recentVideoPath) {
        btnPlayVideo.hidden = NO;
    }
}

- (void)CSVideoCameraViewControllerDelegateActionAlbum {
    [self actionAlbum:nil];
}

@end