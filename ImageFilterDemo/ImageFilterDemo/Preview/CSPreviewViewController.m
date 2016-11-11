//
//  CSPreviewViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/9/27.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSPreviewViewController.h"
#import "Macro.h"

#import "UIImage+CSCategory.h"

#import "CSPreviewThumbnailDataSourceManager.h"
#import "CSPreviewCollectionViewCell.h"
#import "CSWatermarkViewController.h"

@interface CSPreviewViewController () <

    UICollectionViewDataSource,
    UICollectionViewDelegate
>

@end

@implementation CSPreviewViewController {
    
    UIView *_toolBar;
    
    UIImageView *_previewImageView;
    
    UICollectionView *_collectionViewPreview;
    
    UICollectionView *_collectionViewThumbnail;
    CSPreviewThumbnailDataSourceManager *thumbnailDataSourceManager;
    
    NSIndexPath *currentIndexPath;
    CGFloat currentOffsetPreview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCollectionViewThumbnail];
    
    [self initCollectionViewPreview];
    
    [self initToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    currentIndexPath = [NSIndexPath indexPathForItem:(thumbnailDataSourceManager.photoAssets.count - 1) inSection:0];
    [_collectionViewThumbnail scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [_collectionViewPreview scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
//    currentOffsetPreview = _collectionViewPreview.contentOffset.x;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Top Bar

- (void)initToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    _toolBar.backgroundColor = RGBAHEX(0x0, 0.5f);
    [self.view addSubview:_toolBar];
    
    // Album
    UILabel *lbAlbum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    lbAlbum.textAlignment = NSTextAlignmentCenter;
    lbAlbum.textColor = [UIColor whiteColor];
    lbAlbum.text = @"Album";
    [_toolBar addSubview:lbAlbum];
    
    // Close
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnClose setBackgroundImage:[UIImage imageNamed:@"btnClose"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:btnClose];
    
    // watermark
    UIButton *btnWatermark = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_toolBar.frame) - 100, 0, 100, 40)];
    [btnWatermark setTitle:@"Watermark" forState:UIControlStateNormal];
    [btnWatermark addTarget:self action:@selector(actionBtnWatermark:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:btnWatermark];
    
    lbAlbum.center      = _toolBar.center;
    btnClose.center     = CGPointMake(btnClose.center.x, lbAlbum.center.y);
    btnWatermark.center = CGPointMake(btnWatermark.center.x, lbAlbum.center.y);
}

- (void)actionClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionBtnWatermark:(UIButton *)sender {
    CSPreviewCollectionViewCell *cell = (CSPreviewCollectionViewCell *)[[_collectionViewPreview visibleCells] firstObject];
    
    CSWatermarkViewController *watermarkVC = [[CSWatermarkViewController alloc] init];
    watermarkVC.image = cell.imageView.image;
    [self presentViewController:watermarkVC animated:YES completion:nil];
}

#pragma mark - collectionView thumnnail

- (void)initCollectionViewThumbnail
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 95, kCSScreenWidth, 40);
    _collectionViewThumbnail = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionViewThumbnail.backgroundColor = [UIColor whiteColor];
    _collectionViewThumbnail.showsHorizontalScrollIndicator = NO;
    _collectionViewThumbnail.pagingEnabled = YES;
    [self.view addSubview:_collectionViewThumbnail];
    
    [_collectionViewThumbnail registerNib:[UINib nibWithNibName:@"CSAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"kCSPreviewCollectionViewCellThumbnail"];
    
    thumbnailDataSourceManager = [CSPreviewThumbnailDataSourceManager sharedInstance];
    thumbnailDataSourceManager.collectionViewThumbnail = _collectionViewThumbnail;
    
    _collectionViewThumbnail.dataSource = thumbnailDataSourceManager;
    _collectionViewThumbnail.delegate = thumbnailDataSourceManager;
}

#pragma mark - collectionView preview

- (void)initCollectionViewPreview
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionViewPreview = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionViewPreview.backgroundColor = [UIColor blackColor];
    _collectionViewPreview.showsHorizontalScrollIndicator = NO;
    _collectionViewPreview.pagingEnabled = YES;
    [self.view insertSubview:_collectionViewPreview atIndex:0];
    
    [_collectionViewPreview registerClass:[CSPreviewCollectionViewCell class] forCellWithReuseIdentifier:kCSPreviewCollectionViewCellIdentifier];
    
    _collectionViewPreview.dataSource = self;
    _collectionViewPreview.delegate = self;
    
    thumbnailDataSourceManager.collectionViewPreview = _collectionViewPreview;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return thumbnailDataSourceManager.photoAssets.count;
}

- (CSPreviewCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CSPreviewCollectionViewCell *cell = (CSPreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCSPreviewCollectionViewCellIdentifier forIndexPath:indexPath];
    
    PHAsset *asset = thumbnailDataSourceManager.photoAssets[indexPath.item];
    [[PHImageManager defaultManager] cancelImageRequest:cell.imageRequestID];
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(256, 256)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                     
         NSLog(@"data source result size : %@", NSStringFromCGSize(result.size));
         dispatch_async(dispatch_get_main_queue(), ^{
             cell.imageView.image = result;
         });
         
                                            }];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                
                                                NSLog(@"data source result size : %@", NSStringFromCGSize(result.size));
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    cell.imageView.image = result;
                                                });
                                                
                                            }];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

//    NSArray *arr = [_collectionViewPreview indexPathsForVisibleItems];
//    NSLog(@"arr : %@", arr);
//    NSIndexPath *indexPath = [_collectionViewPreview indexPathForItemAtPoint:self.view.center];
//    NSLog(@"indexPath : %@", indexPath);
    
    CGPoint offset = scrollView.contentOffset;
    
    [_collectionViewThumbnail setContentOffset:CGPointMake(offset.x / 10, 0) animated:YES];
    
//    NSArray *cellArr = [_collectionViewPreview indexPathsForVisibleItems];
    
//    thumbnailDataSourceManager.indexPathSelected = [cellArr firstObject];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
