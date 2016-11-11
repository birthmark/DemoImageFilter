
//
//  CSWatermarkViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/11/11.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSWatermarkViewController.h"
#import "CSWatermarkCollectionViewCell.h"

@interface CSWatermarkViewController ()
<
    UICollectionViewDataSource,
    UICollectionViewDelegate
>

@end

@implementation CSWatermarkViewController
{
    UIImageView *_imageView;
    
    UICollectionView *_collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initImageView];
    
    [self initCollectionView];
    
    [self addBtnBack];
    
    [self addBtnShare];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBtnBack{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 20 - 30, 100, 30)];
    [btn setTitle:@"Close" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionBack:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addBtnShare
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 20 - 30, 100, 30)];
    [btn setTitle:@"Share" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionBtnShare:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionBtnShare:(UIButton *)sender
{
    UIGraphicsBeginImageContextWithOptions(_imageView.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_imageView.layer renderInContext:context];
    CSWatermarkCollectionViewCell *cell = _collectionView.visibleCells.firstObject;
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(retImage, nil, nil, nil);
}

- (void)initImageView
{
    _imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = _image;
    [self.view addSubview:_imageView];
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[CSWatermarkCollectionViewCell class] forCellWithReuseIdentifier:kCSWatermarkCollectionViewCellIdentifier];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (CSWatermarkCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSWatermarkCollectionViewCell *cell = (CSWatermarkCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCSWatermarkCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.watermarkType = indexPath.item;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
