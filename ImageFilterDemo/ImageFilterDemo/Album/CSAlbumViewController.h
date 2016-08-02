//
//  CSAlbumViewController.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSAlbumViewControllerDelegate <NSObject>

- (void)CSAlbumViewControllerDelegateDone;

@end


@interface CSAlbumViewController : UIViewController

@property (nonatomic, weak) id<CSAlbumViewControllerDelegate> delegate;

@end
