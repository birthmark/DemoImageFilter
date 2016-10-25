//
//  CSPreviewThumbnailDataSourceManager.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/10/12.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSPreviewThumbnailDataSourceManager.h"
#import "UIImage+CSCategory.h"

#define kCellOffset 2
#define kCellCountOfALine 3

#define kHeaderHeight 50
#define kFooterHeight 100


@implementation CSPreviewThumbnailDataSourceManager

+ (instancetype)sharedInstance {
    static CSPreviewThumbnailDataSourceManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initUICollectionViewDataSource];
    });
    return sharedInstance;
}

- (void)initUICollectionViewDataSource {
    
    _photoAssets = [[NSMutableArray alloc] init];
    
    // 获取PHAsset
    PHFetchResult<PHAssetCollection *> *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *album in albums) {
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:album options:nil];
        for (PHAsset *asset in assets) {
            [_photoAssets addObject:asset];
        }
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoAssets.count;
}

- (CSAlbumCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CSAlbumCollectionViewCell *cell = (CSAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"kCSPreviewCollectionViewCellThumbnail" forIndexPath:indexPath];
    
    CGFloat widthCell = (kCSScreenWidth - kCellOffset * (kCellCountOfALine - 1)) / kCellCountOfALine;
    CGSize targetSize = CGSizeMake(widthCell * 2, widthCell * 2);
    
    [[PHImageManager defaultManager] cancelImageRequest:cell.imageRequestID];
    cell.imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:_photoAssets[indexPath.item]
                                                                    targetSize:targetSize
                                                                   contentMode:PHImageContentModeAspectFit
                                                                       options:nil
                                                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                     
                                                                     NSLog(@"data source result size : %@", NSStringFromCGSize(result.size));
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         cell.imageView.image = [result cs_imageFitTargetSize:targetSize];
                                                                     });
                                                                     
                                                                 }];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CSAlbumCollectionViewCell *cell = (CSAlbumCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PHAsset *selectedPHAsset = _photoAssets[indexPath.item];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"offset : %f", scrollView.contentOffset.x);
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(20, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

@end
