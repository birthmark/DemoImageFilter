//
//  CSAlbumDataSourceManager.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/8.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "CSAlbumCollectionViewCell.h"

#import "Macro.h"

#define kCSAlbumUICollectionViewCell @"CSAlbumUICollectionViewCell"

#define kCSAlbumUICollectionViewHeader @"CSAlbumUICollectionViewHeader"

#define kCSAlbumUICollectionViewFooter @"CSAlbumUICollectionViewFooter"


@protocol CSAlbumDataSourceManagerDelegate <NSObject>

- (void)didSelectPHAsset:(PHAsset *)asset fromRect:(CGRect)rect;

@end

@interface CSAlbumDataSourceManager : NSObject <

    UICollectionViewDataSource,
    UICollectionViewDelegate
>

@property (nonatomic, weak) id<CSAlbumDataSourceManagerDelegate> delegate;

@property (nonatomic, copy) NSMutableArray<PHAsset *> *photoAssets;

+ (instancetype)sharedInstance;

@end
