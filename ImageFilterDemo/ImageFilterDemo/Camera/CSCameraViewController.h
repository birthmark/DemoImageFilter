//
//  CSCameraViewController.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSCameraViewControllerDelegate <NSObject>

- (void)CSCameraViewControllerDelegateDoneWithImage:(UIImage *)image;

- (void)CSCameraViewControllerDelegateActionAlbum;

@end


@interface CSCameraViewController : UIViewController

@property (nonatomic, weak) id<CSCameraViewControllerDelegate> delegate;

@end
