//
//  AnimatorShowDetailForPresentingMHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 31.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHUIImageViewContentViewAnimation;

@interface MHGalleryPresentationTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>

@property (nonatomic) MHUIImageViewContentViewAnimation *transitionImageView;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGPoint changedPoint;
@property (nonatomic, assign) id <UIViewControllerContextTransitioning> context;

@property (nonatomic) UIImageView *presentingImageView;
@property (nonatomic, assign) BOOL interactive;

@end
