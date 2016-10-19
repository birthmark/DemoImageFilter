//
//  CSAlbumViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/2.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSAlbumViewController.h"
#import "CSAlbumDataSourceManager.h"

#import "BeautyCenterViewController.h"


typedef void (^CSPhotoKitManagerResultBlock)(BOOL success, NSError *error);


@interface CSAlbumViewController () <

    CSAlbumDataSourceManagerDelegate
>

@end

@implementation CSAlbumViewController {

    UIView *_topBar;
    
    UICollectionView *_collectionView;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTopBar];
    
    [self initUICollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:[CSAlbumDataSourceManager sharedInstance].photoAssets.count - 1 inSection:0];
    [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(_topBar.frame), kCSScreenWidth, kCSScreenHeight - CGRectGetHeight(_topBar.frame));
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"CSAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCSAlbumUICollectionViewCell];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCSAlbumUICollectionViewHeader];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCSAlbumUICollectionViewFooter];
    
    CSAlbumDataSourceManager *manager = [CSAlbumDataSourceManager sharedInstance];
    _collectionView.dataSource = manager;
    _collectionView.delegate = manager;
    
    manager.delegate = self;
}

#pragma mark - <CSAlbumDataSourceManagerDelegate>

- (void)didSelectPHAsset:(PHAsset *)asset fromRect:(CGRect)rect {
    NSLog(@"didSelectPHAsset rect : %@", NSStringFromCGRect(rect));
    
//    UIView *view = [[UIView alloc] initWithFrame:rect];
//    view.backgroundColor = [UIColor redColor];
//    [self.view addSubview:view];
    
    [self deleteAssets:@[asset] resultBlock:^(BOOL success, NSError *error) {
        NSLog(@"success : %d", success);
    }];
    
//    BeautyCenterViewController *beautyCenter = [[BeautyCenterViewController alloc] init];
//    beautyCenter.asset = asset;
//    [self presentViewController:beautyCenter animated:YES completion:nil];
}

- (void)createAlbum:(NSString *)title resultBlock:(CSPhotoKitManagerResultBlock)resultBlock
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
    } completionHandler:^(BOOL success, NSError *error) {
        if (resultBlock) {
            resultBlock(success, error);
        }
    }];
}

- (void)deleteAssets:(NSArray *)assets resultBlock:(CSPhotoKitManagerResultBlock)resultBlock
{
    NSMutableArray *deleteAssets = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        @autoreleasepool {
            [deleteAssets addObject:asset];
        }
        
    }
    if (0 == deleteAssets.count) {
        if (resultBlock) {
            resultBlock(YES, nil);
        }
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:deleteAssets];
    } completionHandler:^(BOOL success, NSError *error) {
        if (resultBlock) {
            resultBlock(success, error);
        }
    }];
}

@end
