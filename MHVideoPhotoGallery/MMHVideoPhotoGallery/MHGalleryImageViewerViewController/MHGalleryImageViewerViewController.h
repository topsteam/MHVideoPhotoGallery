//
//  MHGalleryImageViewerViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"

@class MHScrollViewLabel;
@class MHTransitionShowOverView;
@class MHTransitionDismissMHGallery;
@class MHGalleryController;

@interface MHGalleryImageViewerViewController : UIViewController<UIPageViewControllerDelegate,
                                                                UIPageViewControllerDataSource,
                                                                UINavigationControllerDelegate,
                                                                UIScrollViewDelegate,
                                                                UIGestureRecognizerDelegate,
                                                                UITextViewDelegate>

@property (nonatomic) MHTransitionPresentMHGallery *interactivePresentationTranstion;
@property (nonatomic) MHTransitionCustomization *transitionCustomization;
@property (nonatomic) MHUICustomization *UICustomization;
@property (nonatomic) MHScrollViewLabel *titleLabel;
@property (nonatomic) MHScrollViewLabel *descriptionLabel;
@property (nonatomic) NSArray *galleryItems;
@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) UIImageView *presentingFromImageView;
@property (nonatomic) UIImageView *dismissFromImageView;
@property (nonatomic, readonly) NSInteger numberOfGalleryItems;
@property (nonatomic, readonly) MHGradientView *bottomSuperView;
@property (nonatomic, readonly) MHGradientView *topSuperView;
@property (nonatomic, readonly) MHGalleryViewMode viewModeForBarStyle;
@property (nonatomic, getter = isUserScrolling) BOOL userScrolls;
@property (nonatomic, getter = isHiddingToolBarAndNavigationBar) BOOL hiddingToolBarAndNavigationBar;

- (MHGalleryController *)galleryViewController;

- (void)updateToolBarForItem:(MHGalleryItem *)item;

- (void)changeToPlayButton;

- (void)changeToPauseButton;

- (void)reloadData;

@end
