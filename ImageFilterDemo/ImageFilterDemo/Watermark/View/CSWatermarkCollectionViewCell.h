//
//  CSWatermarkCollectionViewCell.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/11/11.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CSWatermarkType) {
    CSWatermarkType_None = 0,
    CSWatermarkType_1,
    CSWatermarkType_2,
};

static NSString *const kCSWatermarkCollectionViewCellIdentifier = @"kCSWatermarkCollectionViewCellIdentifier";

@interface CSWatermarkCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) CSWatermarkType watermarkType;

@end
