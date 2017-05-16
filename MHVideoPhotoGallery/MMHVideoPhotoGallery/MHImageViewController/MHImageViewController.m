//
//  MHImageViewController.m
//  MHVideoPhotoGallery
//
//  Created by tstepanov on 29.03.17.
//  Copyright © 2017 Mario Hahn. All rights reserved.
//

#import "MHImageViewController.h"

#import "MHGalleryImageViewerViewController.h"
#import "MHOverviewController.h"
#import "MHTransitionShowShareView.h"
#import "MHTransitionShowOverView.h"
#import "MHGallerySharedManagerPrivate.h"
#import "Masonry.h"
#import "MHGradientView.h"
#import "MHBarButtonItem.h"
#import "MHPinchGestureRecognizer.h"

@interface MHImageViewController ()

@property (nonatomic, readwrite, weak) MHGalleryImageViewerViewController *galleryViewerViewController;

@property (nonatomic) UIButton *moviewPlayerButtonBehinde;
@property (nonatomic) UIToolbar *moviePlayerToolBarTop;
@property (nonatomic) UISlider *slider;
@property (nonatomic) UIProgressView *videoProgressView;
@property (nonatomic) UILabel *leftSliderLabel;
@property (nonatomic) UILabel *rightSliderLabel;

@property (nonatomic) NSTimer *movieTimer;
@property (nonatomic) NSTimer *movieDownloadedTimer;

@property (nonatomic) UIPanGestureRecognizer *pan;
@property (nonatomic) MHPinchGestureRecognizer *pinch;

@property (nonatomic) NSInteger wholeTimeMovie;

@property (nonatomic) CGPoint pointToCenterAfterResize;
@property (nonatomic) CGFloat scaleToRestoreAfterResize;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGPoint lastPointPop;

@property (nonatomic) BOOL shouldPlayVideo;

@end

@implementation MHImageViewController

#pragma mark - MHImageViewController methods

+ (MHImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem *)item
                                              viewController:(MHGalleryImageViewerViewController *)galleryViewerViewController {
    MHImageViewController *imageViewController;
    if (item) {
        imageViewController = [self.alloc initWithMHMediaItem:item
                                               viewController:galleryViewerViewController];
    }
    return imageViewController;
}

- (instancetype)initWithMHMediaItem:(MHGalleryItem *)mediaItem
                     viewController:(MHGalleryImageViewerViewController *)galleryViewerViewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.galleryViewerViewController = galleryViewerViewController;
        self.view.backgroundColor = [UIColor blackColor];
        self.shouldPlayVideo = NO;
        self.item = mediaItem;
        [self setupScrollView];
        [self setupImageView];
        [self.scrollView addSubview:self.imageView];
        [self setupGestureRecognizers];
        [self setupActivityIndicatorView];
        [self.scrollView addSubview:self.act];
        if (self.item.galleryType  == MHGalleryTypeVideo) {
            [self setupMoviePlayer];
        }
        [self setupImage];
    }
    return self;
}

- (void)stopMovie {
    self.shouldPlayVideo = NO;
    
    [self stopTimer];
    
    self.playingVideo = NO;
    [self.moviePlayer pause];
    
    [self.view bringSubviewToFront:self.playButton];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
    [self.galleryViewerViewController changeToPlayButton];
}

- (void)removeAllMoviePlayerViewsAndNotifications {
    
    self.videoDownloaded = NO;
    self.currentTimeMovie =0;
    [self stopTimer];
    [self stopMovieDownloadTimer];
    
    
    self.playingVideo =NO;
    
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:MPMoviePlayerLoadStateDidChangeNotification
                                                object:self.moviePlayer];
    
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:MPMoviePlayerPlaybackDidFinishNotification
                                                object:self.moviePlayer];
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                object:self.moviePlayer];
    
    
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [self addPlayButtonToView];
    self.playButton.hidden =NO;
    self.playButton.frame = CGRectMake(self.galleryViewerViewController.view.frame.size.width/2-36, self.galleryViewerViewController.view.frame.size.height/2-36, 72, 72);
    [self.moviewPlayerButtonBehinde removeFromSuperview];
    [self.galleryViewerViewController changeToPlayButton];
    [self updateTimerLabels];
    [self.slider setValue:0 animated:NO];
}

- (void)playButtonPressed {
    if (!self.playingVideo) {
        
        [self bringMoviePlayerToFront];
        
        self.playButton.hidden = YES;
        self.playingVideo =YES;
        
        if (self.moviePlayer) {
            [self.moviePlayer play];
            [self.galleryViewerViewController changeToPauseButton];
            
        }
        else {
            UIActivityIndicatorView *act = [UIActivityIndicatorView.alloc initWithFrame:self.view.bounds];
            act.tag = 304;
            [self.view addSubview:act];
            [act startAnimating];
            self.shouldPlayVideo = YES;
        }
        if (!self.movieTimer) {
            self.movieTimer = [NSTimer timerWithTimeInterval:0.01f
                                                      target:self
                                                    selector:@selector(movieTimerChanged:)
                                                    userInfo:nil
                                                     repeats:YES];
            [NSRunLoop.currentRunLoop addTimer:self.movieTimer forMode:NSRunLoopCommonModes];
        }
        
    }
    else {
        [self stopMovie];
    }
}

- (void)centerImageView {
    if (self.imageView.image) {
        CGRect frame  = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
        
        if (self.scrollView.contentSize.width==0 && self.scrollView.contentSize.height==0) {
            frame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,self.scrollView.bounds);
        }
        
        CGSize boundsSize = self.scrollView.bounds.size;
        
        CGRect frameToCenter = CGRectMake(0,0 , frame.size.width, frame.size.height);
        
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        }
        else {
            frameToCenter.origin.x = 0;
        }if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        }
        else {
            frameToCenter.origin.y = 0;
        }
        self.imageView.frame = frameToCenter;
    }
}

#pragma mark - Lifecycle methods

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.item.galleryType == MHGalleryTypeVideo) {
        if (self.moviePlayer) {
            [self autoPlayVideo];
            return;
        }
        __weak typeof(self) weakSelf = self;
        [[MHGallerySharedManager sharedManager] getURLForMediaPlayerWithURL:self.item.URL success:^(NSURL *URL, NSError *error) {
            if (error || URL == nil) {
                [weakSelf changePlayButtonToUnPlay];
            }
            else {
                [weakSelf addMoviePlayerToViewWithURL:URL];
                [weakSelf autoPlayVideo];
            }
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.interactiveOverView) {
        if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
            return YES;
        }
        return NO;
    }
    if (self.interactiveTransition) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return YES;
        }
        return NO;
    }
    if (self.galleryViewerViewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if ((self.pageIndex ==0 || self.pageIndex == self.galleryViewerViewController.numberOfGalleryItems -1)) {
            if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")] ) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (self.interactiveOverView || self.interactiveTransition) {
        return NO;
    }
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ) {
        return YES;
    }
    if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
        return YES;
    }
    if (self.galleryViewerViewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if ((self.pageIndex ==0 || self.pageIndex == self.galleryViewerViewController.numberOfGalleryItems -1) && [gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (self.interactiveOverView) {
        if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
            if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class] && self.scrollView.zoomScale ==1) {
                return YES;
            }
            else {
                return NO;
            }
        }
    }
    if (self.galleryViewerViewController.isUserScrolling) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return NO;
        }
    }
    if ([gestureRecognizer isEqual:self.pan] && self.scrollView.zoomScale !=1) {
        return NO;
    }
    if (self.interactiveTransition) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return YES;
        }
        return NO;
    }
    if (self.galleryViewerViewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if ((self.pageIndex ==0 || self.pageIndex == self.galleryViewerViewController.numberOfGalleryItems -1) && [gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
            return YES;
        }
    }
    
    return YES;
}

#pragma mark - Setup methods

- (void)setupScrollView {
    self.scrollView = [UIScrollView.alloc initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.scrollView.delegate = self;
    self.scrollView.tag = 406;
    self.scrollView.maximumZoomScale = 3;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.userInteractionEnabled = YES;
    [self.view addSubview:self.scrollView];
}

- (void)setupImageView {
    self.imageView = [UIImageView.alloc initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.tag = 506;
}

- (void)setupActivityIndicatorView {
    self.act = [UIActivityIndicatorView.alloc initWithFrame:self.view.bounds];
    self.act.hidesWhenStopped = YES;
    self.act.tag = 507;
    self.act.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.scrollView addSubview:self.act];
}

- (void)setupMoviePlayer {
    [self addPlayButtonToView];
    
    self.moviePlayerToolBarTop = [UIToolbar.alloc initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height + ([UIApplication sharedApplication].statusBarHidden ? 0 : 20), self.view.frame.size.width, 44)];
    self.moviePlayerToolBarTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.moviePlayerToolBarTop.alpha = 0;
    self.moviePlayerToolBarTop.barTintColor = self.galleryViewerViewController.UICustomization.barTintColor;
    [self.view addSubview:self.moviePlayerToolBarTop];
    
    self.currentTimeMovie =0;
    self.wholeTimeMovie =0;
    
    self.videoProgressView = [UIProgressView.alloc initWithFrame:CGRectMake(57, 21, self.view.frame.size.width-114, 3)];
    self.videoProgressView.layer.borderWidth =0.5;
    self.videoProgressView.layer.borderColor =[UIColor colorWithWhite:0 alpha:0.3].CGColor;
    self.videoProgressView.trackTintColor =[UIColor clearColor];
    self.videoProgressView.progressTintColor = [self.galleryViewerViewController.UICustomization.videoProgressTintColor colorWithAlphaComponent:0.3f];
    self.videoProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.moviePlayerToolBarTop addSubview:self.videoProgressView];
    
    self.slider = [UISlider.alloc initWithFrame:CGRectMake(55, 0, self.view.frame.size.width-110, 44)];
    self.slider.maximumValue =10;
    self.slider.minimumValue =0;
    self.slider.minimumTrackTintColor = self.galleryViewerViewController.UICustomization.videoProgressTintColor;
    self.slider.maximumTrackTintColor = [self.galleryViewerViewController.UICustomization.videoProgressTintColor colorWithAlphaComponent:0.2f];
    [self.slider setThumbImage:MHGalleryImage(@"sliderPoint") forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderDidDragExit:) forControlEvents:UIControlEventTouchUpInside];
    self.slider.autoresizingMask =UIViewAutoresizingFlexibleWidth;
    [self.moviePlayerToolBarTop addSubview:self.slider];
    
    self.leftSliderLabel = [UILabel.alloc initWithFrame:CGRectMake(8, 0, 40, 43)];
    self.leftSliderLabel.font =[UIFont systemFontOfSize:14];
    self.leftSliderLabel.text = @"00:00";
    self.leftSliderLabel.textColor = self.galleryViewerViewController.UICustomization.videoProgressTintColor;
    [self.moviePlayerToolBarTop addSubview:self.leftSliderLabel];
    
    self.rightSliderLabel = [UILabel.alloc initWithFrame:CGRectZero];
    self.rightSliderLabel.frame = CGRectMake(self.galleryViewerViewController.view.frame.size.width-50, 0, 50, 43);
    self.rightSliderLabel.font = [UIFont systemFontOfSize:14];
    self.rightSliderLabel.text = @"-00:00";
    self.rightSliderLabel.textColor = self.galleryViewerViewController.UICustomization.videoProgressTintColor;
    self.rightSliderLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.moviePlayerToolBarTop addSubview:self.rightSliderLabel];
    
    self.scrollView.maximumZoomScale = 1;
    self.scrollView.minimumZoomScale =1;
}

- (void)setupGestureRecognizers {
    self.pinch = [MHPinchGestureRecognizer.alloc initWithTarget:self
                                                         action:@selector(userDidPinch:)];
    self.pinch.delegate = self;
    
    self.pan = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(userDidPan:)];
    UITapGestureRecognizer *doubleTap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired =2;
    
    UITapGestureRecognizer *imageTap =[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(handelImageTap:)];
    imageTap.numberOfTapsRequired =1;
    
    [self.imageView addGestureRecognizer:doubleTap];
    
    self.pan.delegate = self;
    
    if (self.galleryViewerViewController.transitionCustomization.interactiveDismiss) {
        [self.imageView addGestureRecognizer:self.pan];
        self.pan.maximumNumberOfTouches =1;
        self.pan.delaysTouchesBegan = YES;
    }
    if (self.galleryViewerViewController.UICustomization.showOverView) {
        [self.scrollView addGestureRecognizer:self.pinch];
    }
    
    [self.view addGestureRecognizer:imageTap];
    [imageTap requireGestureRecognizerToFail: doubleTap];
}

- (void)setupImage {
    __weak typeof(self) weakSelf = self;
    [self.act startAnimating];
    switch (self.item.galleryType) {
        case MHGalleryTypeImage: {
            [self.imageView setImageForMHGalleryItem:self.item imageType:MHImageTypeFull success:^(UIImage *image, NSError *error) {
                __weak typeof(weakSelf) strongSelf = weakSelf;
                if (!image) {
                    strongSelf.scrollView.maximumZoomScale = 1;
                    [strongSelf changeToErrorImage];
                }
                [strongSelf.act stopAnimating];
            }];
        }
            break;
        case MHGalleryTypeVideo: {
            [[MHGallerySharedManager sharedManager] startDownloadingThumbImageURL:self.item.URL success:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                BOOL success = error == nil;
                __weak typeof(weakSelf) strongSelf = weakSelf;
                if (success) {
                    [strongSelf handleGeneratedThumb:image
                                       videoDuration:videoDuration
                                           urlString:self.item.URL.absoluteString];
                }
                else {
                    [strongSelf changeToErrorImage];
                }
                [strongSelf.act stopAnimating];
            }];
        }
            break;
    }
}

#pragma mark - Private methods

- (CGFloat)checkProgressValue:(CGFloat)progress {
    CGFloat progressChecked = progress;
    if (progressChecked < 0) {
        progressChecked = -progressChecked;
    }
    if (progressChecked >= 1) {
        progressChecked = 0.99;
    }
    return progressChecked;
}

- (void)userDidPinch:(UIPinchGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale < 1) {
            self.imageView.frame = self.scrollView.frame;
            
            self.lastPointPop = [recognizer locationInView:self.view];
            self.interactiveOverView = [MHTransitionShowOverView new];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            recognizer.cancelsTouchesInView = YES;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (recognizer.numberOfTouches < 2) {
            recognizer.enabled = NO;
            recognizer.enabled = YES;
        }
        CGPoint point = [recognizer locationInView:self.view];
        self.interactiveOverView.scale = recognizer.scale;
        self.interactiveOverView.changedPoint = CGPointMake(self.lastPointPop.x - point.x, self.lastPointPop.y - point.y) ;
        [self.interactiveOverView updateInteractiveTransition:1-recognizer.scale];
        self.lastPointPop = point;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (recognizer.scale < 0.65) {
            [self.interactiveOverView finishInteractiveTransition];
        }
        else {
            [self.interactiveOverView cancelInteractiveTransition];
        }
        self.interactiveOverView = nil;
    }
}

- (void)userDidPan:(UIPanGestureRecognizer *)recognizer {
    BOOL isInterfaceLandscape = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)UIDevice.currentDevice.orientation);
    if (isInterfaceLandscape) {
        //FIXME: temporary condition, implement interactive transition for landscape.
        return;
    }
    BOOL userScrolls = self.galleryViewerViewController.userScrolls;
    if (self.galleryViewerViewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if (!self.interactiveTransition) {
            if (self.galleryViewerViewController.numberOfGalleryItems == 1) {
                userScrolls = NO;
                self.galleryViewerViewController.userScrolls = NO;
            }
            else {
                if (self.pageIndex == 0) {
                    if ([recognizer translationInView:self.view].x >= 0) {
                        userScrolls = NO;
                        self.galleryViewerViewController.userScrolls = NO;
                    }
                    else {
                        recognizer.cancelsTouchesInView = YES;
                        recognizer.enabled =NO;
                        recognizer.enabled =YES;
                    }
                }
                if ((self.pageIndex == self.galleryViewerViewController.numberOfGalleryItems - 1)) {
                    if ([recognizer translationInView:self.view].x <= 0) {
                        userScrolls = NO;
                        self.galleryViewerViewController.userScrolls = NO;
                    }
                    else {
                        recognizer.cancelsTouchesInView = YES;
                        recognizer.enabled = NO;
                        recognizer.enabled = YES;
                    }
                }
            }
        }
        else {
            userScrolls = NO;
        }
    }
    
    if (!userScrolls || recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat progressY = (self.startPoint.y - [recognizer translationInView:self.view].y)/(self.view.frame.size.height/2);
        progressY = [self checkProgressValue:progressY];
        CGFloat progressX = (self.startPoint.x - [recognizer translationInView:self.view].x)/(self.view.frame.size.width/2);
        progressX = [self checkProgressValue:progressX];
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.startPoint = [recognizer translationInView:self.view];
        }
        else if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (!self.interactiveTransition) {
                self.startPoint = [recognizer translationInView:self.view];
                self.lastPoint = [recognizer translationInView:self.view];
                self.interactiveTransition = [MHGalleryDismissTransition new];
                
                switch (UIApplication.sharedApplication.statusBarOrientation) {
                    case UIInterfaceOrientationLandscapeLeft:
                        self.interactiveTransition.orientationBeforeDismissAngle = -M_PI/2;
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        break;
                        self.interactiveTransition.orientationBeforeDismissAngle = M_PI/2;
                    default:
                        self.interactiveTransition.orientationBeforeDismissAngle = 0;
                        break;
                }
                
                self.interactiveTransition.interactive = YES;
                self.interactiveTransition.moviePlayer = self.moviePlayer;
                
                MHGalleryController *galleryViewController = [self.galleryViewerViewController galleryViewController];
                if (galleryViewController.finishedCallback) {
                    galleryViewController.finishedCallback(self.pageIndex,self.imageView.image,self.interactiveTransition,self.galleryViewerViewController.viewModeForBarStyle);
                }
            }
            else {
                CGPoint currentPoint = [recognizer translationInView:self.view];
                
                if (self.galleryViewerViewController.transitionCustomization.fixXValueForDismiss) {
                    self.interactiveTransition.changedPoint = CGPointMake(self.startPoint.x, self.lastPoint.y-currentPoint.y);
                }
                else {
                    self.interactiveTransition.changedPoint = CGPointMake(self.lastPoint.x-currentPoint.x, self.lastPoint.y-currentPoint.y);
                }
                progressY = [self checkProgressValue:progressY];
                progressX = [self checkProgressValue:progressX];
                
                if (!self.galleryViewerViewController.transitionCustomization.fixXValueForDismiss) {
                    if (progressX> progressY) {
                        progressY = progressX;
                    }
                }
                
                [self.interactiveTransition updateInteractiveTransition:progressY];
                self.lastPoint = [recognizer translationInView:self.view];
            }
            
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            if (self.interactiveTransition) {
                CGFloat velocityY = [recognizer velocityInView:self.view].y;
                if (velocityY < 0) {
                    velocityY = -velocityY;
                }
                if (!self.galleryViewerViewController.transitionCustomization.fixXValueForDismiss) {
                    if (progressX > progressY) {
                        progressY = progressX;
                    }
                }
                
                if (progressY > 0.35 || velocityY > 700) {
                    MHStatusBar().alpha = MHShouldShowStatusBar() ? 1 : 0;
                    [self.interactiveTransition finishInteractiveTransition];
                }
                else {
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self.interactiveTransition cancelInteractiveTransition];
                }
                self.interactiveTransition = nil;
            }
        }
    }
}

- (void)setImageForImageViewWithImage:(UIImage *)image
                                error:(NSError *)error {
    if (!image) {
        self.scrollView.maximumZoomScale  =1;
        [self changeToErrorImage];
    }
    else {
        self.imageView.image = image;
    }
    [self.act stopAnimating];
}

- (void)changeToErrorImage {
    self.imageView.image = MHGalleryImage(@"error");
}

- (void)changePlayButtonToUnPlay {
    [self.playButton setImage:MHGalleryImage(@"unplay")
                     forState:UIControlStateNormal];
}

- (void)autoPlayVideo {
    if (self.galleryViewerViewController.galleryViewController.autoplayVideos) {
        [self playButtonPressed];
    }
}

- (void)handleGeneratedThumb:(UIImage *)image
               videoDuration:(NSInteger)videoDuration
                   urlString:(NSString *)urlString {
    self.wholeTimeMovie = videoDuration;
    self.rightSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:videoDuration addMinus:YES];
    
    self.slider.maximumValue = videoDuration;
    [self.view viewWithTag:508].hidden =NO;
    self.imageView.image = image;
    
    self.playButton.frame = CGRectMake(self.galleryViewerViewController.view.frame.size.width/2-36, self.galleryViewerViewController.view.frame.size.height/2-36, 72, 72);
    self.playButton.hidden = NO;
    [self.act stopAnimating];
}

- (void)sliderDidDragExit:(UISlider *)slider {
    if (self.playingVideo) {
        [self.moviePlayer play];
    }
}

- (void)sliderDidChange:(UISlider *)slider {
    if (self.moviePlayer) {
        [self.moviePlayer pause];
        self.moviePlayer.currentPlaybackTime = slider.value;
        self.currentTimeMovie = slider.value;
        [self updateTimerLabels];
    }
}

- (void)changeToPlayable {
    self.videoWasPlayable = YES;
    if (!self.galleryViewerViewController.isHiddingToolBarAndNavigationBar) {
        self.moviePlayerToolBarTop.alpha = 1;
    }
    
    self.moviePlayer.view.hidden = NO;
    [self.view bringSubviewToFront:self.moviePlayer.view];
    
    self.moviewPlayerButtonBehinde = [UIButton.alloc initWithFrame:self.view.bounds];
    [self.moviewPlayerButtonBehinde addTarget:self action:@selector(handelImageTap:) forControlEvents:UIControlEventTouchUpInside];
    self.moviewPlayerButtonBehinde.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view bringSubviewToFront:self.scrollView];
    [self.view addSubview:self.moviewPlayerButtonBehinde];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
    [self.view bringSubviewToFront:self.playButton];
    
    if (self.galleryViewerViewController.transitionCustomization.interactiveDismiss) {
        [self.moviewPlayerButtonBehinde addGestureRecognizer:self.pan];
    }
    
    if (self.playingVideo) {
        [self bringMoviePlayerToFront];
    }
    if (self.shouldPlayVideo) {
        self.shouldPlayVideo = NO;
        if (self.pageIndex == self.galleryViewerViewController.pageIndex) {
            [self playButtonPressed];
        }
    }
}

- (void)loadStateDidChange:(NSNotification *)notification {
    MPMoviePlayerController *player = notification.object;
    MPMovieLoadState loadState = player.loadState;
    if (loadState & MPMovieLoadStatePlayable) {
        if (!self.videoWasPlayable) {
            [self performSelectorOnMainThread:@selector(changeToPlayable)
                                   withObject:nil
                                waitUntilDone:YES];
        }
        
    }
    if (loadState & MPMovieLoadStatePlaythroughOK) {
        self.videoDownloaded = YES;
    }
    
    if (loadState & MPMovieLoadStateStalled) {
        
        [self performSelectorOnMainThread:@selector(stopMovie)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void)updateTimerLabels {
    
    if (self.currentTimeMovie <=0) {
        self.leftSliderLabel.text =@"00:00";
        
        self.rightSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:self.wholeTimeMovie addMinus:YES];
    }
    else {
        self.leftSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:self.currentTimeMovie addMinus:NO];
        self.rightSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:self.wholeTimeMovie-self.currentTimeMovie addMinus:YES];
    }
}

- (void)changeProgressBehinde:(NSTimer *)timer {
    if (self.moviePlayer.playableDuration !=0) {
        [self.videoProgressView setProgress:self.moviePlayer.playableDuration/self.moviePlayer.duration];
        if ((self.moviePlayer.playableDuration == self.moviePlayer.duration)&& (self.moviePlayer.duration !=0)) {
            [self stopMovieDownloadTimer];
        }
    }
}

- (void)movieTimerChanged:(NSTimer *)timer{
    self.currentTimeMovie = self.moviePlayer.currentPlaybackTime;
    if (!self.slider.isTracking) {
        [self.slider setValue:self.moviePlayer.currentPlaybackTime animated:NO];
    }
    [self updateTimerLabels];
}

- (void)addPlayButtonToView {
    if (self.playButton) {
        [self.playButton removeFromSuperview];
    }
    self.playButton = [UIButton.alloc initWithFrame:self.galleryViewerViewController.view.bounds];
    self.playButton.frame = CGRectMake(self.galleryViewerViewController.view.frame.size.width/2-36, self.galleryViewerViewController.view.frame.size.height/2-36, 72, 72);
    [self.playButton setImage:MHGalleryImage(@"playButton") forState:UIControlStateNormal];
    self.playButton.tag =508;
    self.playButton.hidden =YES;
    [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
}

- (void)stopMovieDownloadTimer {
    [self.movieDownloadedTimer invalidate];
    self.movieDownloadedTimer = nil;
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    self.playingVideo = NO;
    [self.galleryViewerViewController changeToPlayButton];
    self.playButton.hidden =NO;
    [self.view bringSubviewToFront:self.playButton];
    [self stopTimer];
    
    self.moviePlayer.currentPlaybackTime =0;
    [self movieTimerChanged:nil];
    [self updateTimerLabels];
    
}

- (void)stopTimer {
    [self.movieTimer invalidate];
    self.movieTimer = nil;
}

- (void)addMoviePlayerToViewWithURL:(NSURL*)URL {
    
    self.videoWasPlayable = NO;
    
    self.moviePlayer = MPMoviePlayerController.new;
    self.moviePlayer.backgroundView.backgroundColor = [self.galleryViewerViewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    self.moviePlayer.view.backgroundColor = [self.galleryViewerViewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.contentURL = URL;
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(loadStateDidChange:)
                                               name:MPMoviePlayerLoadStateDidChangeNotification
                                             object:self.moviePlayer];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(moviePlayBackDidFinish:)
                                               name:MPMoviePlayerPlaybackDidFinishNotification
                                             object:self.moviePlayer];
    
    self.moviePlayer.shouldAutoplay = NO;
    self.moviePlayer.view.frame = self.view.bounds;
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.moviePlayer.view.hidden = YES;
    
    [self.view addSubview:self.moviePlayer.view];
    
    self.playingVideo =NO;
    
    self.movieDownloadedTimer = [NSTimer timerWithTimeInterval:0.06f
                                                        target:self
                                                      selector:@selector(changeProgressBehinde:)
                                                      userInfo:nil
                                                       repeats:YES];
    
    [NSRunLoop.currentRunLoop addTimer:self.movieDownloadedTimer forMode:NSRunLoopCommonModes];
    
    [self changeToPlayable];
}

- (void)bringMoviePlayerToFront {
    [self.view bringSubviewToFront:self.moviePlayer.view];
    [self.view bringSubviewToFront:self.moviewPlayerButtonBehinde];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
}

- (MHGalleryViewMode)currentViewMode {
    if (self.galleryViewerViewController.isHiddingToolBarAndNavigationBar) {
        return MHGalleryViewModeImageViewerNavigationBarHidden;
    }
    return MHGalleryViewModeImageViewerNavigationBarShown;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.moviePlayer.backgroundView.backgroundColor = [self.galleryViewerViewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    self.scrollView.backgroundColor = [self.galleryViewerViewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    
    if (self.galleryViewerViewController.isHiddingToolBarAndNavigationBar) {
        self.act.color = [UIColor whiteColor];
        self.moviePlayerToolBarTop.alpha =0;
    }
    else {
        if (self.moviePlayerToolBarTop) {
            if (self.item.galleryType == MHGalleryTypeVideo) {
                if (self.videoWasPlayable && self.wholeTimeMovie >0) {
                    self.moviePlayerToolBarTop.alpha =1;
                }
            }
        }
        self.act.color = [UIColor blackColor];
    }
    if (self.item.galleryType == MHGalleryTypeVideo) {
        
        if (self.moviePlayer) {
            [self.slider setValue:self.moviePlayer.currentPlaybackTime animated:NO];
        }
        
        if (self.imageView.image) {
            self.playButton.frame = CGRectMake(self.galleryViewerViewController.view.frame.size.width/2-36, self.galleryViewerViewController.view.frame.size.height/2-36, 72, 72);
        }
        self.leftSliderLabel.frame = CGRectMake(8, 0, 40, 43);
        self.rightSliderLabel.frame =CGRectMake(self.galleryViewerViewController.view.bounds.size.width-50, 0, 50, 43);
        
        if (UIApplication.sharedApplication.statusBarOrientation != UIInterfaceOrientationPortrait) {
            if (self.view.bounds.size.width < self.view.bounds.size.height) {
                self.rightSliderLabel.frame =CGRectMake(self.view.bounds.size.height-50, 0, 50, 43);
                if (self.imageView.image) {
                    self.playButton.frame = CGRectMake(self.view.bounds.size.height/2-36, self.view.bounds.size.width/2-36, 72, 72);
                }
            }
        }
        self.moviePlayerToolBarTop.frame =CGRectMake(0,44+([UIApplication sharedApplication].statusBarHidden?0:20), self.view.frame.size.width, 44);
        if (!MHISIPAD) {
            if (UIApplication.sharedApplication.statusBarOrientation != UIInterfaceOrientationPortrait) {
                self.moviePlayerToolBarTop.frame =CGRectMake(0,32+([UIApplication sharedApplication].statusBarHidden?0:20), self.view.frame.size.width, 44);
            }
        }
        
    }
}

- (void)changeUIForViewMode:(MHGalleryViewMode)viewMode {
    float alpha = 0;
    
    if (viewMode == MHGalleryViewModeImageViewerNavigationBarShown) {
        alpha = 1;
    }
    
    self.moviePlayer.backgroundView.backgroundColor = [self.galleryViewerViewController.UICustomization MHGalleryBackgroundColorForViewMode:viewMode];
    self.scrollView.backgroundColor = [self.galleryViewerViewController.UICustomization MHGalleryBackgroundColorForViewMode:viewMode];
    self.galleryViewerViewController.pageViewController.view.backgroundColor = [self.galleryViewerViewController.UICustomization MHGalleryBackgroundColorForViewMode:viewMode];
    
    self.navigationController.navigationBar.alpha = alpha;
    self.galleryViewerViewController.toolbar.alpha = alpha;
    
    self.galleryViewerViewController.topSuperView.alpha = alpha;
    self.galleryViewerViewController.descriptionLabel.alpha = alpha;
    self.galleryViewerViewController.bottomSuperView.alpha = alpha;
    
    if (!MHShouldShowStatusBar()) {
        alpha = 0;
    }
    MHStatusBar().alpha = alpha;
}

- (void)handelImageTap:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.galleryViewerViewController.isHiddingToolBarAndNavigationBar) {
        if ([gestureRecognizer respondsToSelector:@selector(locationInView:)]) {
            CGPoint tappedLocation = [gestureRecognizer locationInView:self.view];
            if (CGRectContainsPoint(self.moviePlayerToolBarTop.frame, tappedLocation)) {
                return;
            }
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (self.moviePlayerToolBarTop) {
                self.moviePlayerToolBarTop.alpha =0;
            }
            [self changeUIForViewMode:MHGalleryViewModeImageViewerNavigationBarHidden];
        } completion:^(BOOL finished) {
            
            self.galleryViewerViewController.hiddingToolBarAndNavigationBar = YES;
            self.navigationController.navigationBar.hidden  =YES;
            self.galleryViewerViewController.toolbar.hidden =YES;
        }];
    }
    else {
        self.navigationController.navigationBar.hidden = NO;
        self.galleryViewerViewController.toolbar.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self changeUIForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
            if (self.moviePlayerToolBarTop) {
                if (self.item.galleryType == MHGalleryTypeVideo) {
                    self.moviePlayerToolBarTop.alpha =1;
                }
            }
        } completion:^(BOOL finished) {
            self.galleryViewerViewController.hiddingToolBarAndNavigationBar = NO;
        }];
        
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (([self.imageView.image isEqual:MHGalleryImage(@"error")]) || (self.item.galleryType == MHGalleryTypeVideo)) {
        return;
    }
    
    if (self.scrollView.zoomScale >1) {
        [self.scrollView setZoomScale:1 animated:YES];
        return;
    }
    [self centerImageView];
    
    CGRect zoomRect;
    CGFloat newZoomScale = (self.scrollView.maximumZoomScale);
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    zoomRect.size.height = [self.imageView frame].size.height / newZoomScale;
    zoomRect.size.width  = [self.imageView frame].size.width  / newZoomScale;
    
    touchPoint = [self.scrollView convertPoint:touchPoint fromView:self.imageView];
    
    zoomRect.origin.x    = touchPoint.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = touchPoint.y - ((zoomRect.size.height / 2.0));
    
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView.subviews firstObject];
}

- (void)prepareToResize {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    self.pointToCenterAfterResize = [self.scrollView convertPoint:boundsCenter toView:self.imageView];
    self.scaleToRestoreAfterResize = self.scrollView.zoomScale;
}

- (void)recoverFromResizing {
    self.scrollView.zoomScale = MIN(self.scrollView.maximumZoomScale, MAX(self.scrollView.minimumZoomScale, _scaleToRestoreAfterResize));
    CGPoint boundsCenter = [self.scrollView convertPoint:self.pointToCenterAfterResize fromView:self.imageView];
    CGPoint offset = CGPointMake(boundsCenter.x - self.scrollView.bounds.size.width / 2.0,
                                 boundsCenter.y - self.scrollView.bounds.size.height / 2.0);
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.scrollView.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.scrollView.contentSize;
    CGSize boundsSize = self.scrollView.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    if (self.moviePlayerToolBarTop) {
        self.moviePlayerToolBarTop.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height+([UIApplication sharedApplication].statusBarHidden?0:20), self.view.frame.size.width,44);
        self.leftSliderLabel.frame = CGRectMake(8, 0, 40, 43);
        self.rightSliderLabel.frame = CGRectMake(self.view.frame.size.width-20, 0, 50, 43);
    }
    self.playButton.frame = CGRectMake(self.galleryViewerViewController.view.frame.size.width/2-36, self.galleryViewerViewController.view.frame.size.height/2-36, 72, 72);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*self.scrollView.zoomScale, self.view.bounds.size.height*self.scrollView.zoomScale);
    self.imageView.frame = CGRectMake(0,0 , self.scrollView.contentSize.width,self.scrollView.contentSize.height);
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self prepareToResize];
    [self recoverFromResizing];
    [self centerImageView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerImageView];
}

@end
