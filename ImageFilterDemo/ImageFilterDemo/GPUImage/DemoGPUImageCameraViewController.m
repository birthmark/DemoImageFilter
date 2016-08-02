//
//  DemoGPUImageCameraViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "DemoGPUImageCameraViewController.h"

#import "CSCameraViewController.h"
#import "CSAlbumViewController.h"

@interface DemoGPUImageCameraViewController () <

    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    CSCameraViewControllerDelegate,
    CSAlbumViewControllerDelegate
>

@end

@implementation DemoGPUImageCameraViewController {
    
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
    [btn setTitle:@"Camera" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionCamera:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionCamera:(UIButton *)sender {
    CSCameraViewController *cameraVC = [[CSCameraViewController alloc] init];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}

- (void)actionAlbum:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    return;
    
    CSAlbumViewController *albumVC = [[CSAlbumViewController alloc] init];
    [self presentViewController:albumVC animated:YES completion:nil];
}

- (void)addUIImageView {
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
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
        imageView.image = savedImage;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - <CSCameraViewControllerDelegate>

- (void)CSCameraViewControllerDelegateDoneWithImage:(UIImage *)image; {
    imageView.image = image;
}

- (void)CSCameraViewControllerDelegateActionAlbum {
    [self actionAlbum:nil];
}

#pragma mark - <CSAlbumViewControllerDelegate>

- (void)CSAlbumViewControllerDelegateDone {
    
}

@end
