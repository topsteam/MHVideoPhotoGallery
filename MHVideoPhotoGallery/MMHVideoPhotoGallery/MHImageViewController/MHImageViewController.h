//
//  MHImageViewController.h
//  MHVideoPhotoGallery
//
//  Created by tstepanov on 29.03.17.
//  Copyright © 2017 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MHGallery.h"
#import "MHScrollViewLabel.h"

@class MHTransitionShowOverView;
@class MHGalleryDismissTransition;
@class MHPinchGestureRecognizer;
@class MHGalleryImageViewerViewController;

@interface MHImageViewController : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic) MHGalleryItem *item;

@property (nonatomic, readonly, weak) MHGalleryImageViewerViewController *galleryViewerViewController;

@property (nonatomic) MHGalleryDismissTransition *interactiveTransition;
@property (nonatomic) MHTransitionShowOverView *interactiveOverView;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIActivityIndicatorView *act;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) MPMoviePlayerController *moviePlayer;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSInteger currentTimeMovie;

@property (nonatomic, getter = isPlayingVideo) BOOL playingVideo;
@property (nonatomic, getter = isPausingVideo) BOOL pausingVideo;
@property (nonatomic) BOOL videoWasPlayable;
@property (nonatomic) BOOL videoDownloaded;

- (void)stopMovie;

- (void)removeAllMoviePlayerViewsAndNotifications;

- (void)playButtonPressed;

- (void)centerImageView;

+ (MHImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item
                                              viewController:(MHGalleryImageViewerViewController*)galleryViewerViewController;

@end
