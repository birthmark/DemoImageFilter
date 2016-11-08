//
//  CSPreviewCollectionViewCell.h
//  ImageFilterDemo
//
//  Created by zj－db0465 on 16/11/8.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

static NSString *const kCSPreviewCollectionViewCellIdentifier = @"kCSPreviewCollectionViewCellIdentifier";

@interface CSPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end
