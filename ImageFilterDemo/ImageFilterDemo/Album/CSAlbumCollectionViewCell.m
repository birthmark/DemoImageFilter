//
//  CSAlbumCollectionViewCell.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/9.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSAlbumCollectionViewCell.h"

@implementation CSAlbumCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _imageRequestID = PHInvalidImageRequestID;
    
    _downloadMaskView.hidden = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _imageRequestID = PHInvalidImageRequestID;
    
    _downloadMaskView.hidden = YES;
    [_pieProgress stopProgress];
}

@end
