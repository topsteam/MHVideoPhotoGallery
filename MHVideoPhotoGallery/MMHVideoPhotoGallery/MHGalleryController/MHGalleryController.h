//
//  MHGalleryController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHGallery.h"

@class MHGalleryController;
@class MHOverviewController;
@class MHGalleryImageViewerViewController;
@class MHGalleryItem;
@class MHTransitionDismissMHGallery;
@class MHBarButtonItem;

@protocol MHGalleryDelegate<NSObject>

@optional

- (void)galleryController:(MHGalleryController *)galleryController
             didShowIndex:(NSInteger)index;

- (BOOL)galleryController:(MHGalleryController *)galleryController
          shouldHandleURL:(NSURL *)URL;

- (NSArray<MHBarButtonItem *> *)customizeableToolBarItems:(NSArray<MHBarButtonItem *> *)toolBarItems
                                           forGalleryItem:(MHGalleryItem *)galleryItem;

@end

@protocol MHGalleryDataSource<NSObject>

@required

/**
 *  @param index which is currently needed
 *  @return MHGalleryItem
 */
- (MHGalleryItem *)itemForIndex:(NSInteger)index;

/**
 *  @param galleryController
 *  @return the number of Items you want to Display
 */
- (NSInteger)numberOfItemsInGallery:(MHGalleryController *)galleryController;

@end

typedef void (^MHGalleryFinishedCallback)(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode);

@interface MHGalleryController : UINavigationController <MHGalleryDataSource>

@property (nonatomic, assign) id<MHGalleryDelegate> galleryDelegate;
@property (nonatomic, assign) id<MHGalleryDataSource> dataSource;
@property (nonatomic) UIImageView *presentingFromImageView;
@property (nonatomic) MHGalleryImageViewerViewController *imageViewerViewController;
@property (nonatomic) MHOverviewController *overViewViewController;
@property (nonatomic) MHTransitionPresentMHGallery *interactivePresentationTransition;
@property (nonatomic, assign) MHGalleryViewMode presentationStyle;
@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyleMH;
@property (nonatomic, copy) MHGalleryFinishedCallback finishedCallback;

/**
 Default NO
 */
@property (nonatomic,assign) BOOL autoplayVideos;

/**
 From which index you want to present the Gallery.
 */
@property (nonatomic,assign) NSInteger presentationIndex;

/**
 You can set an Array of GalleryItems or you can use the dataSource.
 */
@property (nonatomic) NSArray<MHGalleryItem *> *galleryItems;

/**
 Use transitionCustomization to Customize the GalleryControllers transitions
 */
@property (nonatomic) MHTransitionCustomization *transitionCustomization;

/**
 Use UICustomization to Customize the GalleryControllers UI
 */
@property (nonatomic) MHUICustomization *UICustomization;

/**
 There are 3 types to present MHGallery.
 @param presentationStyle description of all 3 Types:
 MHGalleryViewModeImageViewerNavigationBarHidden: the NaviagtionBar and the Toolbar is hidden.
 You can also set the backgroundcolor for this state in the UICustomization
 MHGalleryViewModeImageViewerNavigationBarShown: the NavigationBar and the Toolbar is shown.
 You can also set the backgroundcolor for this state in the UICustomization
 MHGalleryViewModeOverView: presents the GalleryOverView.
 @return MHGalleryController
 */
+ (instancetype)galleryWithPresentationStyle:(MHGalleryViewMode)presentationStyle;

//- (id)initWithPresentationStyle:(MHGalleryViewMode)presentationStyle;

/**
 *  Reloads the View from the Datasource.
 */
- (void)reloadData;

@end

@interface UIViewController(MHGalleryViewController)<UIViewControllerTransitioningDelegate>

/**
 For presenting MHGalleryController.
 @param galleryController your created GalleryController
 @param animated          animated or nonanimated
 @param completion        complitionBlock
 */
- (void)presentMHGalleryController:(MHGalleryController *)galleryController
                          animated:(BOOL)animated
                        completion:(void (^)(void))completion;

/**
 For dismissing MHGalleryController
 @param flag             animated
 @param dismissImageView if you use Custom transitions set your imageView for the Transition. For example if you use a tableView with imageViews in your cells. If you present MHGallery with an imageView on the first Index and dismiss it on the 4 Index, you have to return the imageView from your cell on the 4 index.
 @param completion       completionBlock
 */
- (void)dismissViewControllerAnimated:(BOOL)animated
                     dismissImageView:(UIImageView *)dismissImageView
                           completion:(void (^)(void))completion;

@end
