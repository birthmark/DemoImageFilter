//
//  CSVideoViewController.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSVideoViewControllerDelegate <NSObject>

- (void)CSVideoViewControllerDelegateDoneWithImage:(UIImage *)image;

- (void)CSVideoViewControllerDelegateActionAlbum;

@end


@interface CSVideoViewController : UIViewController

@property (nonatomic, weak) id<CSVideoViewControllerDelegate> delegate;

@end
