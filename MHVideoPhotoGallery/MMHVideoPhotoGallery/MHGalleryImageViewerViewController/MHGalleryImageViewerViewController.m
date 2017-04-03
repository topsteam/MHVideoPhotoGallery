//
//  MHGalleryImageViewerViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHGalleryImageViewerViewController.h"

#import "Masonry.h"

#import "MHOverviewController.h"
#import "MHTransitionShowShareView.h"
#import "MHTransitionShowOverView.h"
#import "MHGallerySharedManagerPrivate.h"
#import "MHGradientView.h"
#import "MHBarButtonItem.h"
#import "MHImageViewController.h"

@interface UIImage(ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

@interface MHGalleryImageViewerViewController() <MHGalleryLabelDelegate,TTTAttributedLabelDelegate>

@property (nonatomic, readwrite) MHGradientView *bottomSuperView;
@property (nonatomic, readwrite) MHGradientView *topSuperView;
@property (nonatomic) MHBarButtonItem *shareBarButton;
@property (nonatomic) MHBarButtonItem *leftBarButton;
@property (nonatomic) MHBarButtonItem *rightBarButton;
@property (nonatomic) MHBarButtonItem *playStopBarButton;
@property (nonatomic) MHImageViewController *currentImageVC;

@end

@implementation MHGalleryImageViewerViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [UIApplication.sharedApplication setStatusBarStyle:self.galleryViewController.preferredStatusBarStyleMH
                                              animated:YES];
    [self.pageViewController.view.subviews.firstObject setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return  self.galleryViewController.preferredStatusBarStyleMH;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.UICustomization = self.galleryViewController.UICustomization;
    self.transitionCustomization = self.galleryViewController.transitionCustomization;
    self.view.backgroundColor = [self.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
    
    [self setupNavigationBar];
    [self setupNavigationBarItems];
    [self setupPageViewController];
    [self setupToolBar];
    [self setupToolBarItems];
    [self setupTopSuperView];
    [self setupBottomSuperView];
    [self reloadData];
}


#pragma mark - Setup methods

- (void)setupNavigationBar {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.translucent = YES;
    UIImage *coloredImage = [UIImage imageWithColor:self.UICustomization.barTintColor];
    [navBar setBackgroundImage:coloredImage forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];
    navBar.barStyle = self.UICustomization.barStyle;
}

- (void)setupNavigationBarItems {
    UIButton *barButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    [barButton setImage:MHGalleryImage(@"back_arrow_icon") forState:UIControlStateNormal];
    [barButton setTitle:self.UICustomization.backButtonTitle forState:UIControlStateNormal];
    [barButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem =  [[UIBarButtonItem alloc]initWithCustomView:barButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)setupPageViewController {
    NSDictionary *pageViewControllerOptions = @{UIPageViewControllerOptionInterPageSpacingKey : @30.f};
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                             options:pageViewControllerOptions];
    pageViewController.delegate = self;
    pageViewController.dataSource = self;
    pageViewController.automaticallyAdjustsScrollViewInsets = NO;
    self.pageViewController = pageViewController;
    UIScrollView *pageViewControllerScrollView = (UIScrollView *)[self.pageViewController.view.subviews firstObject];
    [pageViewControllerScrollView setDelegate:self];
    UIGestureRecognizer *gesturRecognizer = [[pageViewControllerScrollView gestureRecognizers] firstObject];
    [gesturRecognizer setDelegate:self];
    
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupToolBar {
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.translucent = YES;
    UIImage *coloredImage = [UIImage imageWithColor:self.UICustomization.barTintColor];
    [toolBar setBackgroundImage:coloredImage
             forToolbarPosition:UIBarPositionBottom
                     barMetrics:UIBarMetricsDefault];
    [toolBar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionBottom];
    toolBar.tintColor = self.UICustomization.barButtonsTintColor;
    toolBar.barStyle = self.UICustomization.barStyle;
    toolBar.tag = 307;
    self.toolbar = toolBar;
    [self.view addSubview:self.toolbar];
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

- (void)setupToolBarItems {
    self.playStopBarButton = [[MHBarButtonItem alloc] initWithImage:MHGalleryImage(@"play")
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                               type:MHBarButtonItemTypePlayPause
                                                             action:@selector(playStopButtonPressed)];
    
    self.leftBarButton = [[MHBarButtonItem alloc] initWithImage:MHGalleryImage(@"left_arrow")
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                           type:MHBarButtonItemTypeLeft
                                                         action:@selector(leftPressed:)];
    
    self.rightBarButton = [[MHBarButtonItem alloc] initWithImage:MHGalleryImage(@"right_arrow")
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                            type:MHBarButtonItemTypeRight
                                                          action:@selector(rightPressed:)];
    MHBarButtonItem *barItem;
    if (self.UICustomization.hideShare) {
        barItem = [[MHBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                target:self
                                                                  type:MHBarButtonItemTypeFixed
                                                                action:nil];
    }
    else {
        barItem = [[MHBarButtonItem alloc] initWithImage:MHGalleryImage(@"share_icon")
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                      type:MHBarButtonItemTypeShare
                                                    action:@selector(sharePressed)];
    }
    self.shareBarButton = barItem;
    if (self.UICustomization.hideShare) {
        self.shareBarButton.width = 30.0;
    }
}

- (void)setupTopSuperView {
    MHGradientView *topSuperView = [[MHGradientView alloc] initWithDirection:MHGradientDirectionBottomToTop
                                                            andCustomization:self.UICustomization];
    self.topSuperView = topSuperView;
    [self.view addSubview:self.topSuperView];
    [self.topSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
    }];
    [self setupTitleLabel];
}

- (void)setupTitleLabel {
    MHScrollViewLabel *titleLabel = [[MHScrollViewLabel alloc] init];
    titleLabel.textLabel.labelDelegate = self;
    titleLabel.textLabel.delegate = self;
    titleLabel.textLabel.UICustomization = self.UICustomization;
    self.titleLabel = titleLabel;
    [self.topSuperView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topSuperView.mas_left).with.offset(10);
        make.right.mas_equalTo(self.topSuperView.mas_right).with.offset(-10);
        make.bottom.mas_equalTo(self.topSuperView.mas_bottom).with.offset(-20);
        make.top.mas_equalTo(self.topSuperView.mas_top).with.offset(5);
    }];
}

- (void)setupBottomSuperView {
    MHGradientView *bottomSuperView = [[MHGradientView alloc] initWithDirection:MHGradientDirectionTopToBottom
                                                               andCustomization:self.UICustomization];
    self.bottomSuperView = bottomSuperView;
    [self.view addSubview:self.bottomSuperView];
    [self.bottomSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.toolbar.mas_top);
    }];
    [self setupDescriptionLabel];
}

- (void)setupDescriptionLabel {
    MHScrollViewLabel *descriptionLabel = [[MHScrollViewLabel alloc] init];
    descriptionLabel.textLabel.labelDelegate = self;
    descriptionLabel.textLabel.delegate = self;
    descriptionLabel.textLabel.UICustomization = self.UICustomization;
    descriptionLabel = descriptionLabel;
    [self.bottomSuperView addSubview:self.descriptionLabel];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomSuperView.mas_left).with.offset(10);
        make.right.mas_equalTo(self.bottomSuperView.mas_right).with.offset(-10);
        make.bottom.mas_equalTo(self.bottomSuperView.mas_bottom).with.offset(-5);
        make.top.mas_equalTo(self.bottomSuperView.mas_top).with.offset(20);
    }];
}

- (void)configureDescriptionLabel:(MHGalleryLabel *)label{
    label.labelDelegate = self;
}

- (void)configureTextView:(UITextView *)textView {
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = [UIColor blackColor];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.delegate = self;
}

#pragma mark - MHGalleryLabelDelegate

- (void)galleryLabel:(MHGalleryLabel *)label
  wholeTextDidChange:(BOOL)wholeText {
    //empty implementation
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if ([self.galleryViewController.galleryDelegate respondsToSelector:@selector(galleryController:shouldHandleURL:)]) {
        if ([self.galleryViewController.galleryDelegate galleryController:self.galleryViewController shouldHandleURL:url]) {
            [UIApplication.sharedApplication openURL:url];
        }
        return;
    }
    [UIApplication.sharedApplication openURL:url];
}

#pragma mark - MHGalleryImageViewerViewController

- (MHGalleryController *)galleryViewController {
    if ([self.navigationController isKindOfClass:MHGalleryController.class]) {
        return (MHGalleryController*)self.navigationController;
    }
    return nil;
}

- (void)updateToolBarForItem:(MHGalleryItem *)item {
    [self enableOrDisbaleBarbButtons];
    BOOL isVideoGalleryItem = item.galleryType == MHGalleryTypeVideo;
    if (isVideoGalleryItem) {
        if (self.currentImageVC.isPlayingVideo) {
            [self changeToPauseButton];
        }
        else {
            [self changeToPlayButton];
        }
    }
    NSArray<MHBarButtonItem *> *barButtonItems = [self toolBarButtonItemsWithPlayButton:isVideoGalleryItem];
    [self setToolbarItemsWithBarButtons:barButtonItems
                         forGalleryItem:item];
}

- (void)changeToPlayButton {
    self.playStopBarButton.image = MHGalleryImage(@"play");
}

- (void)changeToPauseButton {
    self.playStopBarButton.image = MHGalleryImage(@"pause");
}

- (void)reloadData {
    if ([self numberOfGalleryItems] > self.pageIndex) {
        MHGalleryItem *item = [self itemForIndex:self.pageIndex];
        MHImageViewController *imageViewController = [MHImageViewController imageViewControllerForMHMediaItem:item
                                                                                               viewController:self];
        imageViewController.pageIndex = self.pageIndex;
        [self.pageViewController setViewControllers:@[imageViewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
        
        [self updateTitleLabelForIndex:self.pageIndex];
        [self updateDescriptionLabelForIndex:self.pageIndex];
        [self updateToolBarForItem:item];
        [self updateTitleForIndex:self.pageIndex];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([self.galleryViewController.galleryDelegate respondsToSelector:@selector(galleryController:shouldHandleURL:)]) {
        return [self.galleryViewController.galleryDelegate galleryController:self.galleryViewController shouldHandleURL:URL];
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:UIButton.class]) {
        if (touch.view.tag != 508) {
            return YES;
        }
    }
    return ([touch.view isKindOfClass:UIControl.class] == NO);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.userScrolls = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.userScrolls = NO;
    [self updateTitleAndDescriptionForScrollView:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateTitleAndDescriptionForScrollView:scrollView];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:MHTransitionShowOverView.class]) {
        return self.currentImageVC.interactiveOverView;
    }
    else {
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (self.currentImageVC.moviePlayer) {
        [self.currentImageVC removeAllMoviePlayerViewsAndNotifications];
    }
    if ([toVC isKindOfClass:MHShareViewController.class]) {
        MHTransitionShowShareView *present = MHTransitionShowShareView.new;
        present.present = YES;
        return present;
    }
    if ([toVC isKindOfClass:MHOverviewController.class]) {
        return MHTransitionShowOverView.new;
    }
    return nil;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    self.pageIndex = [pageViewController.viewControllers.firstObject pageIndex];
    [self showCurrentIndex:self.pageIndex];
    
    if (finished) {
        for (MHImageViewController *imageViewController in previousViewControllers) {
            [self removeVideoPlayerForVC:imageViewController];
        }
    }
    if (completed) {
        [self updateToolBarForItem:[self itemForIndex:self.pageIndex]];
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
       viewControllerAfterViewController:(MHImageViewController *)vc {
    NSInteger currentPageIndex = vc.pageIndex;
    MHGalleryItem *galleryItem = [self nextGalleryItem];
    MHImageViewController *imageViewController = [MHImageViewController imageViewControllerForMHMediaItem:galleryItem
                                                                                           viewController:self];
    imageViewController.pageIndex = currentPageIndex + 1;
    return imageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
      viewControllerBeforeViewController:(MHImageViewController *)vc {
    MHGalleryItem *galleryItem = [self previousGalleryItem];
    MHImageViewController *imageViewController = [MHImageViewController imageViewControllerForMHMediaItem:galleryItem
                                                                                           viewController:self];
    NSInteger currentPageIndex = vc.pageIndex;
    imageViewController.pageIndex = currentPageIndex - 1;
    return imageViewController;
}

#pragma mark - Actions

- (void)leftPressed:(id)sender {
    if (self.currentImageVC.moviePlayer) {
        [self.currentImageVC removeAllMoviePlayerViewsAndNotifications];
    }
    NSUInteger previousPageIndex = self.currentImageVC.pageIndex - 1;
    MHGalleryItem *previousGalleryItem = [self itemForIndex:previousPageIndex];
    MHImageViewController *imageViewController = [MHImageViewController imageViewControllerForMHMediaItem:previousGalleryItem
                                                                                           viewController:self];
    imageViewController.pageIndex = previousPageIndex;
    BOOL previousPhotoIsFirst = previousPageIndex == 0;
    self.leftBarButton.enabled = !previousPhotoIsFirst;
    self.rightBarButton.enabled = YES;
    if (imageViewController) {
        __weak typeof(self) weakSelf = self;
        [self.pageViewController setViewControllers:@[imageViewController]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES
                                         completion:^(BOOL finished) {
                                             weakSelf.pageIndex = imageViewController.pageIndex;
                                             [weakSelf updateToolBarForItem:[weakSelf itemForIndex:weakSelf.pageIndex]];
                                             [weakSelf showCurrentIndex:weakSelf.pageIndex];
                                         }];
    }
}

- (void)rightPressed:(id)sender {
    
    if (self.currentImageVC.moviePlayer) {
        [self.currentImageVC removeAllMoviePlayerViewsAndNotifications];
    }
    NSUInteger nextPageIndex = self.currentImageVC.pageIndex + 1;
    MHGalleryItem *nextGalleryItem = [self itemForIndex:nextPageIndex];
    MHImageViewController *imageViewController = [MHImageViewController imageViewControllerForMHMediaItem:nextGalleryItem
                                                                                           viewController:self];
    imageViewController.pageIndex = nextPageIndex;
    
    BOOL nextPhotoIsLast = nextPageIndex == self.numberOfGalleryItems - 1;
    self.rightBarButton.enabled = !nextPhotoIsLast;
    self.leftBarButton.enabled = YES;
    if (imageViewController) {
        __weak typeof(self) weakSelf = self;
        [self.pageViewController setViewControllers:@[imageViewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:^(BOOL finished) {
                                             weakSelf.pageIndex = imageViewController.pageIndex;
                                             [weakSelf updateToolBarForItem:[weakSelf itemForIndex:weakSelf.pageIndex]];
                                             [weakSelf showCurrentIndex:weakSelf.pageIndex];
                                         }];
    }
}

- (void)sharePressed {
    if (self.UICustomization.showMHShareViewInsteadOfActivityViewController) {
        MHShareViewController *share = [MHShareViewController new];
        share.pageIndex = self.pageIndex;
        share.galleryItems = self.galleryItems;
        [self.navigationController pushViewController:share
                                             animated:YES];
    }
    else {
        if (self.currentImageVC.imageView.image != nil) {
            UIActivityViewController *act = [UIActivityViewController.alloc initWithActivityItems:@[self.currentImageVC.imageView.image] applicationActivities:nil];
            [self presentViewController:act animated:YES completion:nil];
            
            if ([act respondsToSelector:@selector(popoverPresentationController)]) {
                act.popoverPresentationController.barButtonItem = self.shareBarButton;
            }
        }
    }
}

- (void)donePressed {
    if (self.currentImageVC.moviePlayer) {
        [self.currentImageVC removeAllMoviePlayerViewsAndNotifications];
    }
    MHTransitionDismissMHGallery *dismissTransiton = [MHTransitionDismissMHGallery new];
    dismissTransiton.orientationTransformBeforeDismiss = [(NSNumber *)[self.navigationController.view valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    dismissTransiton.finishButtonAction = YES;
    self.currentImageVC.interactiveTransition = dismissTransiton;
    MHGalleryController *galleryViewController = [self galleryViewController];
    if (galleryViewController.finishedCallback) {
        galleryViewController.finishedCallback(self.pageIndex,self.currentImageVC.imageView.image,dismissTransiton,self.viewModeForBarStyle);
    }
}

- (void)playStopButtonPressed {
    for (MHImageViewController *imageViewController in self.pageViewController.viewControllers) {
        if (imageViewController.pageIndex == self.pageIndex) {
            if (imageViewController.isPlayingVideo) {
                [imageViewController stopMovie];
                [self changeToPlayButton];
            }
            else {
                [imageViewController playButtonPressed];
            }
        }
    }
}

- (void)backButtonAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (MHImageViewController *)currentImageVC {
    return self.pageViewController.viewControllers.firstObject;
}

- (NSArray<MHBarButtonItem *> *)toolBarButtonItemsWithPlayButton:(BOOL)withPlayButton {
    MHBarButtonItem *flex = [MHBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                          type:MHBarButtonItemTypeFlexible
                                                                        action:nil];
    MHBarButtonItem *fixed = [MHBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                         target:self
                                                                           type:MHBarButtonItemTypeFixed
                                                                         action:nil];
    fixed.width = 30;
    NSArray *toolBarButtons;
    if (self.UICustomization.showArrows) {
        if (withPlayButton) {
            toolBarButtons = @[fixed, flex,
                               self.leftBarButton, flex,
                               self.playStopBarButton, flex,
                               self.rightBarButton, flex,
                               self.shareBarButton];
        }
        else {
            toolBarButtons = @[fixed, flex,
                               self.leftBarButton, flex,
                               self.rightBarButton, flex,
                               self.shareBarButton];
        }
    }
    else {
        if (withPlayButton) {
            toolBarButtons = @[fixed, flex,
                               self.playStopBarButton, flex,
                               self.shareBarButton];
        }
        else {
            toolBarButtons = @[fixed, flex,
                               self.shareBarButton];
        }
    }
    return toolBarButtons;
}

- (MHGalleryViewMode)viewModeForBarStyle {
    if (self.isHiddingToolBarAndNavigationBar) {
        return MHGalleryViewModeImageViewerNavigationBarHidden;
    }
    return MHGalleryViewModeImageViewerNavigationBarShown;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.topSuperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom);
    }];
    [self.toolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    [self.bottomSuperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.toolbar.mas_top);
    }];
}

- (void)enableOrDisbaleBarbButtons {
    
    self.leftBarButton.enabled  = YES;
    self.rightBarButton.enabled  = YES;
    
    if (self.pageIndex == 0) {
        self.leftBarButton.enabled =NO;
    }
    if(self.pageIndex == self.numberOfGalleryItems-1){
        self.rightBarButton.enabled =NO;
    }
}

- (NSInteger)numberOfGalleryItems {
    return [self.galleryViewController.dataSource numberOfItemsInGallery:self.galleryViewController];
}

- (MHGalleryItem *)nextGalleryItem {
    NSInteger currentPageIndex = self.currentImageVC.pageIndex;
    BOOL currentPageIsLast = currentPageIndex == self.numberOfGalleryItems - 1;
    MHGalleryItem *galleryItem;
    if (!currentPageIsLast) {
        NSUInteger nextPageIndex = currentPageIndex + 1;
        galleryItem = [self itemForIndex:nextPageIndex];
    }
    return galleryItem;
}

- (MHGalleryItem *)previousGalleryItem {
    NSInteger currentPageIndex = self.currentImageVC.pageIndex;
    BOOL currentPageIsFirst = currentPageIndex == 0;
    MHGalleryItem *galleryItem;
    if (!currentPageIsFirst) {
        NSUInteger previousPageIndex = currentPageIndex - 1;
        galleryItem = [self itemForIndex:previousPageIndex];
    }
    return galleryItem;
}

- (MHGalleryItem *)itemForIndex:(NSInteger)index {
    return [self.galleryViewController.dataSource itemForIndex:index];
}

- (void)updateTitleLabelForIndex:(NSInteger)index {
    if (index < self.numberOfGalleryItems) {
        MHGalleryItem *item = [self itemForIndex:index];
        if (item.titleString) {
            if (item.titleString && ![self.titleLabel.textLabel.text isEqualToString:item.titleString]) {
                self.titleLabel.textLabel.wholeText = NO;
            }
            if (![self.titleLabel.textLabel.text isEqual:item.titleString]) {
                self.titleLabel.textLabel.text = item.titleString;
            }
        }
        
        if (item.attributedTitle) {
            if (![self.titleLabel.textLabel.attributedText isEqualToAttributedString:item.attributedTitle]) {
                self.titleLabel.textLabel.wholeText = NO;
            }
            if (![self.titleLabel.textLabel.text isEqualToString:item.attributedTitle.string]) {
                self.titleLabel.textLabel.text = item.attributedTitle;
            }
        }
        self.topSuperView.hidden = item.titleString || item.attributedTitle ? NO : YES;
    }
}

- (void)updateDescriptionLabelForIndex:(NSInteger)index {
    if (index < self.numberOfGalleryItems) {
        MHGalleryItem *item = [self itemForIndex:index];
        
        if (item.descriptionString) {
            if (item.descriptionString && ![self.descriptionLabel.textLabel.text isEqualToString:item.descriptionString]) {
                self.descriptionLabel.textLabel.wholeText = NO;
            }
            if (![self.descriptionLabel.textLabel.text isEqual:item.descriptionString]) {
                self.descriptionLabel.textLabel.text = item.descriptionString;
            }
        }
        
        if (item.attributedString) {
            if (![self.descriptionLabel.textLabel.attributedText isEqualToAttributedString:item.attributedString]) {
                self.descriptionLabel.textLabel.wholeText = NO;
            }
            if (![self.descriptionLabel.textLabel.text isEqualToString:item.attributedString.string]) {
                self.descriptionLabel.textLabel.text = item.attributedString;
            }
        }
        self.bottomSuperView.hidden = item.descriptionString || item.attributedString ? NO : YES;
    }
}

- (void)updateTitleAndDescriptionForScrollView:(UIScrollView *)scrollView {
    NSInteger pageIndex = self.pageIndex;
    if (scrollView.contentOffset.x > (self.view.frame.size.width+self.view.frame.size.width/2)) {
        pageIndex++;
    }
    if (scrollView.contentOffset.x < self.view.frame.size.width/2) {
        pageIndex--;
    }
    [self updateTitleLabelForIndex:pageIndex];
    [self updateDescriptionLabelForIndex:pageIndex];
    [self updateTitleForIndex:pageIndex];
}

- (void)updateTitleForIndex:(NSInteger)pageIndex {
    NSString *localizedString  = MHGalleryLocalizedString(@"imagedetail.title.current");
    self.navigationItem.title = [NSString stringWithFormat:localizedString,@(pageIndex+1),@(self.numberOfGalleryItems)];
}

- (void)removeVideoPlayerForVC:(MHImageViewController *)vc {
    if (vc.pageIndex != self.pageIndex) {
        if (vc.moviePlayer) {
            if (vc.item.galleryType == MHGalleryTypeVideo) {
                if (vc.isPlayingVideo) {
                    [vc stopMovie];
                }
                vc.currentTimeMovie = 0;
            }
        }
    }
}

- (void)setToolbarItemsWithBarButtons:(NSArray *)barButtons
                       forGalleryItem:(MHGalleryItem *)item {
    if ([self.galleryViewController.galleryDelegate respondsToSelector:@selector(customizeableToolBarItems:forGalleryItem:)]) {
        barButtons = [self.galleryViewController.galleryDelegate customizeableToolBarItems:barButtons
                                                                            forGalleryItem:item];
    }
    self.toolbar.items = barButtons;
}

- (void)showCurrentIndex:(NSInteger)currentIndex {
    if ([self.galleryViewController.galleryDelegate respondsToSelector:@selector(galleryController:didShowIndex:)]) {
        [self.galleryViewController.galleryDelegate galleryController:self.galleryViewController
                                                         didShowIndex:currentIndex];
    }
    
}

- (MHImageViewController *)imageViewControllerWithItem:(MHGalleryItem *)item
                                             pageIndex:(NSInteger)pageIndex {
    MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:[self itemForIndex:pageIndex] viewController:self];
    imageViewController.pageIndex  = pageIndex;
    return imageViewController;
}

- (UIInterfaceOrientation)currentOrientation {
    return UIApplication.sharedApplication.statusBarOrientation;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    self.pageViewController.view.bounds = self.view.bounds;
    [self.pageViewController.view.subviews.firstObject setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ];
    
}

@end

@implementation UIImage(ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

