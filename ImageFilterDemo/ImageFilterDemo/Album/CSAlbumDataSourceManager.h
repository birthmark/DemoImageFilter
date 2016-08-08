//
//  CSAlbumDataSourceManager.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/8.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define kScreenSize   [[UIScreen mainScreen] bounds].size
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height


#define kCSAlbumUICollectionViewCell @"CSAlbumUICollectionViewCell"

#define kCSAlbumUICollectionViewHeader @"CSAlbumUICollectionViewHeader"

#define kCSAlbumUICollectionViewFooter @"CSAlbumUICollectionViewFooter"

@interface CSAlbumDataSourceManager : NSObject <

    UICollectionViewDataSource,
    UICollectionViewDelegate
>

+ (instancetype)sharedInstance;

@end
