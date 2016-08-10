//
//  CSAlbumDataSourceManager.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/8.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSAlbumDataSourceManager.h"

@interface CSAlbumDataSourceManager ()

@property (nonatomic, copy) NSMutableArray<PHAsset *> *photoAssets;

@end

@implementation CSAlbumDataSourceManager {

    NSArray *_assets;
    
    dispatch_once_t onceTokenForScrollToEnd;
}

+ (instancetype)sharedInstance {
    static CSAlbumDataSourceManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSAlbumDataSourceManager alloc] init];
        [sharedInstance prepareUICollectionViewDataSource];
    });
    return sharedInstance;
}

- (void)prepareUICollectionViewDataSource {
    _assets = @[
                @"1",@"2",@"3",
                @"1",@"2",@"3",
                @"1",@"2",@"3",
                @"1",@"2",@"3",
                @"1",@"2",@"3",
                @"1",@"2",@"3",
                @"1",@"2",@"3",
                ];
    
    
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoAssets.count;
}

- (CSAlbumCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSAlbumCollectionViewCell *cell = (CSAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCSAlbumUICollectionViewCell forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((arc4random() % 255) / 255.0)
                                           green:((arc4random() % 255) / 255.0)
                                            blue:((arc4random() % 255) / 255.0)
                                           alpha:1.0f];
    
    // 要考虑到scale
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(cell.frame) * scale, CGRectGetHeight(cell.frame) * scale);
    
    [[PHImageManager defaultManager] cancelImageRequest:cell.imageRqeustID];
    cell.imageRqeustID = [[PHImageManager defaultManager] requestImageForAsset:_photoAssets[indexPath.item]
                                                                    targetSize:targetSize
                                                                   contentMode:PHImageContentModeAspectFill
                                                                       options:nil
                                                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                
        NSLog(@"data source result size : %@", NSStringFromCGSize(result.size));
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = result;
        });
                                                
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *view;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kCSAlbumUICollectionViewHeader forIndexPath:indexPath];
        
        view.backgroundColor = [UIColor redColor];
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kCSAlbumUICollectionViewFooter forIndexPath:indexPath];
        
        view.backgroundColor = [UIColor blueColor];
        
    }
    
    return view;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_once(&onceTokenForScrollToEnd, ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(_photoAssets.count - 1) inSection:0];
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    });
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CSAlbumCollectionViewCell *cell = (CSAlbumCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PHAsset *selectedPHAsset = _photoAssets[indexPath.item];
    CGRect fromRect = [collectionView convertRect:cell.frame toView:collectionView.superview];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectPHAsset:fromRect:)]) {
        [_delegate didSelectPHAsset:selectedPHAsset fromRect:fromRect];
    }

    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

#define kCellOffset 2
#define kHeaderHeight 50
#define kFooterHeight 100

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (kScreenWidth - kCellOffset * 3) / 4;
//    CGFloat width = 75;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCellOffset;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCellOffset;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth, kHeaderHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return CGSizeMake(kScreenWidth, kFooterHeight);
    }
    
    return CGSizeZero;
}

@end
