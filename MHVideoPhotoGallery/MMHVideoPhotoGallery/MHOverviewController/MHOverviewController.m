//
//  MHGalleryOverViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHOverviewController.h"
#import "MHGalleryController.h"
#import "MHGallerySharedManagerPrivate.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "SDWebImageManager.h"

@implementation MHIndexPinchGestureRecognizer

@end

@interface MHOverviewController ()

@property (nonatomic) MHTransitionShowDetail *interactivePushTransition;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGFloat startScale;

@end

@implementation MHOverviewController

#pragma mark - MHOverviewController interface

- (UICollectionViewFlowLayout *)layoutForOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationPortrait ) {
        return self.galleryViewController.UICustomization.overViewCollectionViewLayoutPortrait;
    }
    return self.galleryViewController.UICustomization.overViewCollectionViewLayoutLandscape;
}

- (MHGalleryItem *)itemForIndex:(NSInteger)index {
    return [self.galleryViewController.dataSource itemForIndex:index];
}

- (void)pushToImageViewerForIndexPath:(NSIndexPath *)indexPath {
    MHGalleryImageViewerViewController *detail = MHGalleryImageViewerViewController.new;
    detail.pageIndex = indexPath.row;
    detail.galleryItems = self.galleryItems;
    if ([self.navigationController isKindOfClass:MHGalleryController.class]) {
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - Lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title =  MHGalleryLocalizedString(@"overview.title.current");
    
    UIBarButtonItem *doneBarButton = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
    
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    self.collectionView = [UICollectionView.alloc initWithFrame:self.view.bounds
                                           collectionViewLayout:[self layoutForOrientation:UIApplication.sharedApplication.statusBarOrientation]];
    
    self.collectionView.backgroundColor = [self.galleryViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeOverView];
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [self.collectionView registerClass:MHMediaPreviewCollectionViewCell.class
            forCellWithReuseIdentifier:NSStringFromClass(MHMediaPreviewCollectionViewCell.class)];
    
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    UIMenuItem *saveItem = [UIMenuItem.alloc initWithTitle:MHGalleryLocalizedString(@"overview.menue.item.save")
                                                    action:@selector(saveImage:)];
#pragma clang diagnostic pop
    
    UIMenuController.sharedMenuController.menuItems = @[saveItem];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [UIApplication.sharedApplication setStatusBarStyle:self.galleryViewController.preferredStatusBarStyleMH
                                              animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.galleryViewController.preferredStatusBarStyleMH;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Gesture handlers

- (void)userDidRotate:(UIRotationGestureRecognizer *)recognizer {
    if (self.interactivePushTransition) {
        CGFloat angle = recognizer.rotation;
        self.interactivePushTransition.angle = angle;
    }
}

- (void)userDidPinch:(MHIndexPinchGestureRecognizer*)recognizer {
    
    CGFloat scale = recognizer.scale/5;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale>1) {
            self.interactivePushTransition = MHTransitionShowDetail.new;
            self.interactivePushTransition.indexPath = recognizer.indexPath;
            self.lastPoint = [recognizer locationInView:self.view];
            
            MHGalleryImageViewerViewController *detail = MHGalleryImageViewerViewController.new;
            detail.galleryItems = self.galleryItems;
            detail.pageIndex = recognizer.indexPath.row;
            self.startScale = recognizer.scale/8;
            [self.navigationController pushViewController:detail
                                                 animated:YES];
        }
        else {
            recognizer.cancelsTouchesInView = YES;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (recognizer.numberOfTouches <2) {
            recognizer.enabled = NO;
            recognizer.enabled = YES;
        }
        
        CGPoint point = [recognizer locationInView:self.view];
        self.interactivePushTransition.scale = recognizer.scale/8-self.startScale;
        self.interactivePushTransition.changedPoint = CGPointMake(self.lastPoint.x - point.x, self.lastPoint.y - point.y) ;
        [self.interactivePushTransition updateInteractiveTransition:scale];
        self.lastPoint = point;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (scale > 0.5) {
            [self.interactivePushTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePushTransition cancelInteractiveTransition];
        }
        self.interactivePushTransition = nil;
    }
}

#pragma mark - UINavigationControllerDelegate methods

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:MHTransitionShowDetail.class]) {
        return self.interactivePushTransition;
    }
    else {
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (fromVC == self && [toVC isKindOfClass:MHGalleryImageViewerViewController.class]) {
        return [[MHTransitionShowDetail alloc] init];
    }
    else {
        return nil;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.galleryViewController.dataSource numberOfItemsInGallery:self.galleryViewController];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = (MHMediaPreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(MHMediaPreviewCollectionViewCell.class) forIndexPath:indexPath];
    [self makeMHGalleryOverViewCell:(MHMediaPreviewCollectionViewCell*)cell
                        atIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    
    MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    MHGalleryItem *item =  [self itemForIndex:indexPath.row];
    
    UIImage *thumbImage = [SDImageCache.sharedImageCache imageFromDiskCacheForKey:item.URL.absoluteString];
    if (thumbImage) {
        cell.thumbnail.image = thumbImage;
    }
    
    BOOL isLocalImage = [item.URL.absoluteString rangeOfString:MHAssetLibrary].location != NSNotFound;
    if (isLocalImage) {
        [[MHGallerySharedManager sharedManager] getImageFromAssetLibraryWithURL:item.URL assetType:MHAssetImageTypeFull success:^(UIImage *image, NSError *error) {
            cell.thumbnail.image = image;
            [weakSelf pushToImageViewerForIndexPath:indexPath];
        }];
    }
    else {
        [self pushToImageViewerForIndexPath:indexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    MHGalleryItem *item =  [self itemForIndex:indexPath.row];
    if (item.galleryType == MHGalleryTypeImage) {
        if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"saveImage:"]) {
            return YES;
        }
    }
    return NO;
}


- (void)collectionView:(UICollectionView *)collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:UIPasteboardNameGeneral create:NO];
        pasteBoard.persistent = YES;
        MHGalleryItem *item =  [self itemForIndex:indexPath.row];
        [self getImageForItem:item completion:^(UIImage *image) {
            if (image) {
                UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;
                if (image.images) {
                    NSData *data = [NSData dataWithContentsOfFile:[SDImageCache.sharedImageCache defaultCachePathForKey:item.URL.absoluteString]];
                    [pasteboard setData:data forPasteboardType:(__bridge NSString *)kUTTypeGIF];
                }
                else {
                    NSData *data = UIImagePNGRepresentation(image);
                    [pasteboard setData:data forPasteboardType:(__bridge NSString *)kUTTypeImage];
                }
            }
        }];
    }
}

#pragma mark - UIViewControllerRotation methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    self.collectionView.collectionViewLayout = [self layoutForOrientation:toInterfaceOrientation];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Actions

- (void)donePressed {
    self.navigationController.transitioningDelegate = nil;
    
    MHGalleryController *galleryViewController = [self galleryViewController];
    if (galleryViewController.finishedCallback) {
        galleryViewController.finishedCallback(0,nil,nil,MHGalleryViewModeOverView);
    }
}

#pragma mark - Private methods

- (void)getImageForItem:(MHGalleryItem *)item
             completion:(void(^)(UIImage *image))completion {
    [[SDWebImageManager sharedManager] loadImageWithURL:item.URL options:SDWebImageContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completion) {
            completion(image);
        }
    }];
}

- (void)makeMHGalleryOverViewCell:(MHMediaPreviewCollectionViewCell *)cell
                      atIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    
    MHGalleryItem *item =  [self itemForIndex:indexPath.row];
    cell.thumbnail.image = nil;
    cell.videoGradient.hidden = YES;
    cell.videoIcon.hidden = YES;
    
    cell.saveImageBlock = ^(BOOL shouldSave) {
        [weakSelf getImageForItem:item
                       completion:^(UIImage *image) {
                           UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                       }];
    };
    
    cell.videoDurationLength.text = @"";
    cell.thumbnail.backgroundColor = [UIColor lightGrayColor];
    cell.galleryItem = item;
    
    cell.thumbnail.userInteractionEnabled =YES;
    
    MHIndexPinchGestureRecognizer *pinch = [MHIndexPinchGestureRecognizer.alloc initWithTarget:self
                                                                                        action:@selector(userDidPinch:)];
    pinch.indexPath = indexPath;
    [cell.thumbnail addGestureRecognizer:pinch];
    
    UIRotationGestureRecognizer *rotate = [UIRotationGestureRecognizer.alloc initWithTarget:self
                                                                                     action:@selector(userDidRotate:)];
    rotate.delegate = self;
    [cell.thumbnail addGestureRecognizer:rotate];
}

- (MHGalleryController *)galleryViewController {
    if ([self.navigationController isKindOfClass:MHGalleryController.class]) {
        return (MHGalleryController *)self.navigationController;
    }
    return nil;
}

@end
