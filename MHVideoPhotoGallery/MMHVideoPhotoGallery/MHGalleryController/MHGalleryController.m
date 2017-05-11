//
//  MHGalleryController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGalleryController.h"

@implementation MHGalleryController

#pragma mark - MHGalleryController

+ (instancetype)galleryWithPresentationStyle:(MHGalleryViewMode)presentationStyle {
    return [self.class.alloc initWithPresentationStyle:presentationStyle];
}

- (id)initWithPresentationStyle:(MHGalleryViewMode)presentationStyle {
    self = [super initWithNibName:nil bundle:nil];
    if (!self)
        return nil;
    self.autoplayVideos = NO;
    
    self.preferredStatusBarStyleMH = UIStatusBarStyleDefault;
    self.presentationStyle = presentationStyle;
    self.transitionCustomization = MHTransitionCustomization.new;
    self.UICustomization = MHUICustomization.new;
    
    self.overViewViewController= MHOverviewController.new;
    self.imageViewerViewController = MHGalleryImageViewerViewController.new;

    if (presentationStyle == MHGalleryViewModeOverView) {
        self.viewControllers = @[self.overViewViewController];
    }
    else {
        self.viewControllers = @[self.imageViewerViewController];
    }
    return self;
}

- (void)reloadData {
    [self.imageViewerViewController reloadData];
    [self.overViewViewController.collectionView reloadData];
}

#pragma mark - Private methods

- (void)setGalleryItems:(NSArray *)galleryItems{
    self.overViewViewController.galleryItems = galleryItems;
    self.imageViewerViewController.galleryItems = galleryItems;
    _galleryItems = galleryItems;
}

- (void)setPresentationIndex:(NSInteger)presentationIndex {
    self.imageViewerViewController.pageIndex = presentationIndex;
    _presentationIndex = presentationIndex;
}

- (void)setPresentingFromImageView:(UIImageView *)presentingFromImageView {
    self.imageViewerViewController.presentingFromImageView = presentingFromImageView;
    _presentingFromImageView = presentingFromImageView;
}

- (void)setInteractivePresentationTransition:(MHGalleryPresentationTransition *)interactivePresentationTranstion {
    self.imageViewerViewController.interactivePresentationTranstion = interactivePresentationTranstion;
    _interactivePresentationTransition = interactivePresentationTranstion;
}

#pragma mark - MHGalleryDataSource

- (MHGalleryItem *)itemForIndex:(NSInteger)index {
    if (index < 0 || index >= [self numberOfItemsInGallery:self]) {
        return nil;
    }
    return self.galleryItems[index];
}

- (NSInteger)numberOfItemsInGallery:(MHGalleryController *)galleryController {
    return self.galleryItems.count;
}

@end


@implementation UIViewController(MHGalleryViewController)

- (void)presentMHGalleryController:(MHGalleryController *)galleryController
                          animated:(BOOL)animated
                        completion:(void (^)(void))completion {
    
    if (galleryController.UICustomization.useCustomBackButtonImageOnImageViewer) {
        UIBarButtonItem *backBarButton = [UIBarButtonItem.alloc initWithImage:MHTemplateImage(@"ic_square")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:nil];
        galleryController.overViewViewController.navigationItem.backBarButtonItem = backBarButton;
        galleryController.navigationBar.tintColor = galleryController.UICustomization.barButtonsTintColor;
    }
    
    if (galleryController.transitionCustomization.interactiveDismiss) {
        galleryController.transitioningDelegate = self;
        galleryController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
        else {
        galleryController.transitionCustomization.interactiveDismiss = NO;
        galleryController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage = NO;
    }
    //    galleryController.navigationBar.barStyle = galleryController.UICustomization.barStyle;
    galleryController.navigationBar.barTintColor = galleryController.UICustomization.barTintColor;
    
    if (!galleryController.dataSource) {
        galleryController.dataSource = galleryController;
    }
    if (galleryController.presentationStyle == MHGalleryViewModeImageViewerNavigationBarHidden) {
        galleryController.imageViewerViewController.hiddingToolBarAndNavigationBar = YES;
    }
    [self presentViewController:galleryController animated:animated completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag
                     dismissImageView:(UIImageView*)dismissImageView
                           completion:(void (^)(void))completion {
    if ([self isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)self viewControllers].lastObject isKindOfClass:MHGalleryImageViewerViewController.class]) {
        MHGalleryImageViewerViewController *imageViewer = [(UINavigationController*)self viewControllers].lastObject;
        imageViewer.dismissFromImageView = dismissImageView;
    }
    [self dismissViewControllerAnimated:flag completion:completion];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    if ([animator isKindOfClass:MHGalleryPresentationTransition.class]) {
        MHGalleryPresentationTransition *animatorPresent = (MHGalleryPresentationTransition*)animator;
        if (animatorPresent.interactive) {
            return animatorPresent;
        }
        return nil;
    }else {
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if ([animator isKindOfClass:MHGalleryDismissTransition.class]) {
        MHGalleryDismissTransition *animatorDismiss = (MHGalleryDismissTransition*)animator;
        if (animatorDismiss.interactive) {
            return animatorDismiss;
        }
        return nil;
    }else {
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)dismissed  viewControllers].lastObject isKindOfClass:MHGalleryImageViewerViewController.class]) {
        MHGalleryImageViewerViewController *imageViewer = [(UINavigationController*)dismissed  viewControllers].lastObject;
        MHImageViewController *viewer = imageViewer.pageViewController.viewControllers.firstObject;
        
        if (!imageViewer.dismissFromImageView && viewer.interactiveTransition.finishButtonAction) {
            return nil;
        }
        
        if (viewer.interactiveTransition) {
            MHGalleryDismissTransition *detail = viewer.interactiveTransition;
            detail.transitionImageView = imageViewer.dismissFromImageView;
            return detail;
        }
        
        MHGalleryDismissTransition *detail = MHGalleryDismissTransition.new;
        detail.transitionImageView = imageViewer.dismissFromImageView;
        return detail;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    UINavigationController *nav = (UINavigationController*)presented;
    if ([nav isKindOfClass:[UINavigationController class]] && [nav.viewControllers.lastObject  isKindOfClass:MHGalleryImageViewerViewController.class]) {
        MHGalleryImageViewerViewController *imageViewer = nav.viewControllers.lastObject;
        if (imageViewer.interactivePresentationTranstion) {
            MHGalleryPresentationTransition *detail = imageViewer.interactivePresentationTranstion;
            detail.presentingImageView = imageViewer.presentingFromImageView;
            return detail;
        }
        MHGalleryPresentationTransition *detail = MHGalleryPresentationTransition.new;
        detail.presentingImageView = imageViewer.presentingFromImageView;
        return detail;
    }
    return nil;
}

@end
