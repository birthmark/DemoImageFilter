//
//  CSAlbumCoverCollectionViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/10.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSAlbumCoverCollectionViewController.h"
#import <Photos/Photos.h>

#define kScreenSize   [[UIScreen mainScreen] bounds].size
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height


static NSString * const reuseIdentifier = @"CSAlbumCoverCollectionViewCell";

#define kCSAlbumCoverCollectionViewCell @"CSAlbumCoverCollectionViewCell"

#define kCSAlbumCoverCollectionViewHeader @"CSAlbumCoverCollectionViewHeader"

#define kCSAlbumCoverCollectionViewFooter @"CSAlbumCoverCollectionViewFooter"


@interface CSAlbumCoverCollectionViewController () <

    UICollectionViewDataSource,
    UICollectionViewDelegate
>

@property (nonatomic, strong) NSMutableArray<PHFetchResult *> *coverAssets;

@property (nonatomic, strong) UIView *topBar;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation CSAlbumCoverCollectionViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareCoverAssets];
    
    [self initTopBar];
    
    [self initUICollectionView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)prepareCoverAssets {
    self.coverAssets = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取PHAsset
        PHFetchResult<PHAssetCollection *> *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        for (PHAssetCollection *album in albums) {
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:album options:nil];
            [self.coverAssets addObject:assets];
//                    for (PHAsset *asset in assets) {
//                        [self.coverAssets addObject:asset];
//                    }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

#pragma mark - Top Bar

- (void)initTopBar {
    _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    _topBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_topBar];
    
    // Album
    UILabel *lbAlbum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    lbAlbum.textAlignment = NSTextAlignmentCenter;
    lbAlbum.textColor = [UIColor whiteColor];
    lbAlbum.text = @"Album";
    [_topBar addSubview:lbAlbum];
    
    // Close
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnClose setBackgroundImage:[UIImage imageNamed:@"btnClose"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [_topBar addSubview:btnClose];
    
    // Camera
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_topBar.frame) - 40, 0, 40, 40)];
    [btnCamera setBackgroundImage:[UIImage imageNamed:@"btnCamera"] forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(actionCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_topBar addSubview:btnCamera];
    
    lbAlbum.center      = _topBar.center;
    btnClose.center     = CGPointMake(btnClose.center.x, lbAlbum.center.y);
    btnCamera.center    = CGPointMake(btnCamera.center.x, lbAlbum.center.y);
}

- (void)actionClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionCamera:(UIButton *)sender {
    
}

#pragma mark - UIColelctionView

- (void)initUICollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(_topBar.frame), kScreenWidth, kScreenHeight - CGRectGetHeight(_topBar.frame));
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"CSAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCSAlbumCoverCollectionViewCell];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCSAlbumCoverCollectionViewHeader];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCSAlbumCoverCollectionViewFooter];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.coverAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCSAlbumCoverCollectionViewCell forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((arc4random() % 255) / 255.0)
                                           green:((arc4random() % 255) / 255.0)
                                            blue:((arc4random() % 255) / 255.0)
                                           alpha:1.0f];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kScreenWidth, 100);
}

@end