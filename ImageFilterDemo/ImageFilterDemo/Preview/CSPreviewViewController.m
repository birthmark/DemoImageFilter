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
    
    // Camera
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_toolBar.frame) - 40, 0, 40, 40)];
    [btnCamera setBackgroundImage:[UIImage imageNamed:@"btnCamera"] forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(actionCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:btnCamera];
    
    lbAlbum.center      = _toolBar.center;
    btnClose.center     = CGPointMake(btnClose.center.x, lbAlbum.center.y);
    btnCamera.center    = CGPointMake(btnCamera.center.x, lbAlbum.center.y);
}

- (void)actionClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionCamera:(UIButton *)sender {
    
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
    
    [_collectionViewPreview registerNib:[UINib nibWithNibName:@"CSAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"kCSPreviewCollectionViewCellPreview"];
    
    _collectionViewPreview.dataSource = self;
    _collectionViewPreview.delegate = self;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return thumbnailDataSourceManager.photoAssets.count;
}

- (CSAlbumCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CSAlbumCollectionViewCell *cell = (CSAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"kCSPreviewCollectionViewCellPreview" forIndexPath:indexPath];
    
    PHAsset *asset = thumbnailDataSourceManager.photoAssets[indexPath.item];
    [[PHImageManager defaultManager] cancelImageRequest:cell.imageRqeustID];
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:cell.frame.size
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                     
         NSLog(@"data source result size : %@", NSStringFromCGSize(result.size));
         dispatch_async(dispatch_get_main_queue(), ^{
             cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
             cell.imageView.image = result;
         });
         
                                            }];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.x - currentOffsetPreview == -CGRectGetWidth(_collectionViewPreview.frame)) {
//        NSLog(@"another page");
//        
//        currentOffsetPreview = scrollView.contentOffset.x;
//    }
//    NSArray *arr = [_collectionViewPreview indexPathsForVisibleItems];
//    NSLog(@"arr : %@", arr);
//    NSIndexPath *indexPath = [_collectionViewPreview indexPathForItemAtPoint:self.view.center];
//    NSLog(@"indexPath : %@", indexPath);
    
    
    CGFloat offset = scrollView.contentOffset.x;
    
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
