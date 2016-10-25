//
//  CSPreviewThumbnailDataSourceManager.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/10/12.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSPreviewThumbnailDataSourceManager.h"
#import "UIImage+CSCategory.h"
#import "NSIndexSet+Convenience.h"

#define kCellOffset 2
#define kCellCountOfALine 3

#define kHeaderHeight 50
#define kFooterHeight 100

@interface CSPreviewThumbnailDataSourceManager ()
<
    PHPhotoLibraryChangeObserver
>

@end

@implementation CSPreviewThumbnailDataSourceManager
{

    BOOL _isCollectionViewLoaded;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

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
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    // 获取PHAsset
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"endDate"
                                                              ascending:YES]];
    
    PHFetchResult<PHAssetCollection *> *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options];
    
    for (PHAssetCollection *album in albums) {
        if ([album.localizedTitle isEqualToString:@"Camera Roll"]) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                                      ascending:YES]];
            _photoAssets = [PHAsset fetchAssetsInAssetCollection:album options:options];
            break;
        }
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _isCollectionViewLoaded = YES;
    
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

#pragma mark - <PHPhotoLibraryChangeObserver>

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:_photoAssets];
    if (collectionChanges == nil) {
        return;
    }
    
    // Get the new fetch result.
    _photoAssets = [collectionChanges fetchResultAfterChanges];
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!_isCollectionViewLoaded) {
            return ;
        }
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [_collectionViewPreview reloadData];
            [_collectionViewThumbnail reloadData];
            
        } else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            
            NSArray<NSIndexPath *> * removedPaths = [[collectionChanges removedIndexes] aapl_indexPathsFromIndexesWithSection:0];
            NSArray<NSIndexPath *> * insertedPaths = [[collectionChanges insertedIndexes] aapl_indexPathsFromIndexesWithSection:0];
            NSArray<NSIndexPath *> * changedPaths = [[collectionChanges changedIndexes] aapl_indexPathsFromIndexesWithSection:0];
            
            BOOL shouldReload = NO;
            
            if ((changedPaths != nil) + (removedPaths != nil) + (insertedPaths!= nil) > 1) {
                shouldReload = YES;
            }
            
            if (shouldReload) {
                [_collectionViewPreview reloadData];
                [_collectionViewThumbnail reloadData];
                
            } else {
                
                @try {
                    [_collectionViewPreview performBatchUpdates:^{
                        if ([removedPaths count] > 0) {
                            [_collectionViewPreview deleteItemsAtIndexPaths:removedPaths];
                        }
                        
                        if ([insertedPaths count] > 0) {
                            [_collectionViewPreview insertItemsAtIndexPaths:insertedPaths];
                        }
                        
                        if ([changedPaths count] > 0) {
                            [_collectionViewPreview reloadItemsAtIndexPaths:changedPaths];
                        }
                    } completion:^(BOOL finished) {
                        if (_photoAssets.count == 0) {
                            NSLog(@"There is no photo in this album yet!!!");
                        }
                    }];
                    
                    [_collectionViewThumbnail performBatchUpdates:^{
                        if ([removedPaths count] > 0) {
                            [_collectionViewThumbnail deleteItemsAtIndexPaths:removedPaths];
                        }
                        
                        if ([insertedPaths count] > 0) {
                            [_collectionViewThumbnail insertItemsAtIndexPaths:insertedPaths];
                        }
                        
                        if ([changedPaths count] > 0) {
                            [_collectionViewThumbnail reloadItemsAtIndexPaths:changedPaths];
                        }
                    } completion:^(BOOL finished) {
                        if (_photoAssets.count == 0) {
                            NSLog(@"There is no photo in this album yet!!!");
                        }
                    }];
                }
                @catch (NSException *exception) {
                    [_collectionViewPreview reloadData];
                    [_collectionViewThumbnail reloadData];
                }
            }
        }
    });
}

@end
