//
//  MHGalleryDismissTransition.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHUIImageViewContentViewAnimation;
@class MPMoviePlayerController;

@interface MHGalleryDismissTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>

@property (nonatomic) UIImageView *transitionImageView;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGPoint changedPoint;
@property (nonatomic, assign) id <UIViewControllerContextTransitioning> context;
@property (nonatomic, assign) BOOL interactive;

@property (nonatomic) MPMoviePlayerController *moviePlayer;
@property (nonatomic, assign) CGFloat orientationBeforeDismissAngle;
//@property (nonatomic, assign) CGFloat orientationTransformBeforeDismiss;
@property (nonatomic, assign) BOOL finishButtonAction;

@end
