//
//  AnimatorShowDetailForPresentingMHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 31.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHContentViewAnimationImageView;

@interface MHGalleryPresentationTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>

@property (nonatomic) MHContentViewAnimationImageView *transitionImageView;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGPoint changedPoint;
@property (nonatomic, assign) id <UIViewControllerContextTransitioning> context;
@property (nonatomic, assign) BOOL interactive;

@property (nonatomic) UIImageView *presentingImageView;

@end
