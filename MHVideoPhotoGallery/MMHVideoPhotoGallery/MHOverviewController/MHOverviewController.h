//
//  MHGalleryOverViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"
#import "MHGalleryImageViewerViewController.h"
#import "MHTransitionShowDetail.h"
#import "MHMediaPreviewCollectionViewCell.h"

@interface MHIndexPinchGestureRecognizer : UIPinchGestureRecognizer

@property (nonatomic) NSIndexPath *indexPath;

@end

@interface MHOverviewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) MHMediaPreviewCollectionViewCell *clickedCell;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSArray *galleryItems;

- (UICollectionViewFlowLayout *)layoutForOrientation:(UIInterfaceOrientation)orientation;

- (MHGalleryItem*)itemForIndex:(NSInteger)index;

- (void)pushToImageViewerForIndexPath:(NSIndexPath *)indexPath;

@end
