//
//  CSVideoCameraViewController.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSVideoCameraViewControllerDelegate <NSObject>

- (void)CSVideoCameraViewControllerDelegateDoneWithImage:(UIImage *)image;

- (void)CSVideoCameraViewControllerDelegateActionAlbum;

@end


@interface CSVideoCameraViewController : UIViewController

@property (nonatomic, weak) id<CSVideoCameraViewControllerDelegate> delegate;

@end
