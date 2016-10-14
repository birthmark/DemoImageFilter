//
//  CSPreviewThumbnailDataSourceManager.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/10/12.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "CSAlbumCollectionViewCell.h"

@interface CSPreviewThumbnailDataSourceManager : NSObject
<
    UICollectionViewDataSource,
    UICollectionViewDelegate
>

@property (nonatomic, copy) NSMutableArray<PHAsset *> *photoAssets;

+ (instancetype)sharedInstance;

@end
