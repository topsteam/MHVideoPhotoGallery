//
//  MHGalleryPresenterImageView.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 20.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryPresentationTransition.h"
#import "MHGalleryDismissTransition.h"
#import "MHUICustomization.h"
#import "MHTransitionCustomization.h"

@class MHGalleryPresentationTransition;
@class MHGalleryDismissTransition;

typedef void (^MHPresenterImageViewCompletionBlock)(NSInteger currentIndex, UIImage *image, MHGalleryDismissTransition *interactiveTransition, MHGalleryViewMode viewMode);

@interface MHPresenterImageView : UIImageView <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL shoudlUsePanGestureReconizer;
/**
 *  set your Current ViewController
 */
@property (nonatomic) UIViewController *viewController;
/**
 *  set your the Data Source
 */
@property (nonatomic) NSArray *galleryItems;
/**
 *  set the currentIndex
 */
@property (nonatomic) NSInteger currentImageIndex;
@property (nonatomic) MHGalleryPresentationTransition *presenter;
@property (nonatomic, copy) MHPresenterImageViewCompletionBlock finishedCallback;

- (void)setInseractiveGalleryPresentionWithItems:(NSArray *)galleryItems
                               currentImageIndex:(NSInteger)currentImageIndex
                           currentViewController:(UIViewController *)viewController
                                      completion:(MHPresenterImageViewCompletionBlock)completion;

@end
