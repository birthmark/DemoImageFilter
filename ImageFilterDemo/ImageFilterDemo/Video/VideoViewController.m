//
//  VideoViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//


// Video camera using UIImagePickerController

#import "VideoViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import <Photos/Photos.h>

@interface VideoViewController () <

    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
>


@end

@implementation VideoViewController {
    
    UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addBtnBack];
    
    [self addBtns];
    
    [self addUIImageView];
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
}

- (void)actionVideo:(UIButton *)sender {
    [self initVideo];
}

- (void)addUIImageView {
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
}

- (void)initVideo {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 需要引入MobileCoreServices
    // 设置mediaTypes
    NSString *mediaTypes = (__bridge NSString *)kUTTypeMovie;
    picker.mediaTypes = @[mediaTypes];
    picker.delegate = self;
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    picker.videoMaximumDuration = 10.0f;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"videoURL : %@", videoURL);
        
        // 播放使用MPMoviePlayerViewController
        __block MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        player.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        player.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        
        
//        // 保存使用ALAssetsLibrary
//        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
//            
//            if (error == nil) {
//                NSLog(@"video saved ...");
//            }
//            
//            [picker dismissViewControllerAnimated:YES completion:^{
//                [self presentMoviePlayerViewControllerAnimated:player];
//            }];
//        }];
        
        
        // 推荐保存使用PhotoKit
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"video saved ...");
            }
            
            [picker dismissViewControllerAnimated:YES completion:^{
                [self presentMoviePlayerViewControllerAnimated:player];
            }];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
