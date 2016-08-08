//
//  CSAlbumDataSourceManager.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/8.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSAlbumDataSourceManager.h"

@interface CSAlbumDataSourceManager ()

@property (nonatomic, copy) NSArray *assets;

@end

@implementation CSAlbumDataSourceManager {

    NSArray *_assets;
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
    
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCSAlbumUICollectionViewCell forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((arc4random() % 255) / 255.0)
                                           green:((arc4random() % 255) / 255.0)
                                            blue:((arc4random() % 255) / 255.0)
                                           alpha:1.0f];
    
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
