//
//  ExampleViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.09.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "ExampleViewControllerCollectionViewInTableView.h"
#import "MHOverviewController.h"

@implementation UITabBarController (autoRotate)

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end


@implementation UINavigationController (autoRotate)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.viewControllers.lastObject preferredStatusBarStyle];
}

- (BOOL)shouldAutorotate {
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

@end


@implementation TestCell

@end


@interface ExampleViewControllerCollectionViewInTableView ()

@property(nonatomic) NSArray *galleryDataSource;

@end


@implementation ExampleViewControllerCollectionViewInTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CollectionView";
    
    NSURL *tailored1URL = [NSURL URLWithString:@"http://www.tailored-apps.com/wp-content/uploads/2014/01/wien_cropped-350x300.jpg"];
    NSURL *tailored2URL = [NSURL URLWithString:@"http://www.tailored-apps.com/wp-content/uploads/2014/01/hannes.jpg"];
    
    MHGalleryItem *tailored = [MHGalleryItem itemWithURL:tailored1URL
                                             galleryType:MHGalleryTypeImage];
    MHGalleryItem *tailored2 = [MHGalleryItem itemWithURL:tailored2URL
                                              galleryType:MHGalleryTypeImage];
    NSURL *videoURL = [NSURL URLWithString:@"https://instagram.fhen1-1.fna.fbcdn.net/t50.2886-16/17582534_211662269318529_2144443442514624512_n.mp4"];
    
    MHGalleryItem *tailored3 = [MHGalleryItem itemWithURL:videoURL
                                              galleryType:MHGalleryTypeVideo];
    
    NSURL *youtubeVideoURL = [NSURL URLWithString:@"https://www.youtube.com/watch?v=xn0Ah0J5p5Y"];
    MHGalleryItem *youTubeItem = [MHGalleryItem itemWithURL:youtubeVideoURL galleryType:MHGalleryTypeVideo];
    NSURL *vimeoVideoURL = [NSURL URLWithString:@"https://vimeo.com/70546700"];
    MHGalleryItem *vimeoItem = [MHGalleryItem itemWithURL:vimeoVideoURL galleryType:MHGalleryTypeVideo];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(0.0, 2.0);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:@"Lorem https://github.com/mariohahn/MHVideoPhotoGallery ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."];
    
    [string setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15],
                            NSForegroundColorAttributeName : UIColor.whiteColor,
                            NSShadowAttributeName : shadow}
                    range:NSMakeRange(0, string.length)];
    
    
    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:@"elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."];
    
    [string2 setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15],
                             NSForegroundColorAttributeName : UIColor.whiteColor,
                             NSShadowAttributeName : shadow}
                     range:NSMakeRange(0, string2.length)];
    
    NSMutableAttributedString *title  = [[NSMutableAttributedString alloc] initWithString:@"Title Test\nderIstgeil"];
    [title setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15],
                           NSForegroundColorAttributeName : UIColor.whiteColor,
                           NSShadowAttributeName : shadow}
                   range:NSMakeRange(0, title.length)];
    //    uncomment to add strings and shadows to imageViewer
    //    tailored.attributedString = string;
    //    tailored.attributedTitle = title;
    //    tailored2.attributedString = string2;
    
    self.galleryDataSource = @[
                               @[tailored, tailored2],
                               @[tailored3],
                               @[youTubeItem, vimeoItem]
                               ];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.83 green:0.84 blue:0.86 alpha:1];
    [self.tableView reloadData];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([self.presentedViewController isKindOfClass:[MHGalleryController class]]) {
        MHGalleryController *gallerController = (MHGalleryController*)self.presentedViewController;
        return gallerController.preferredStatusBarStyleMH;
    }
    return UIStatusBarStyleDefault;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.galleryDataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.galleryDataSource[collectionView.tag] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 330;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = nil;
    cellIdentifier = @"TestCell";
    
    TestCell *cell = (TestCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[TestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
    layout.itemSize = CGSizeMake(270, 225);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    cell.collectionView.collectionViewLayout = layout;
    
    [cell.collectionView registerClass:[MHMediaPreviewCollectionViewCell class] forCellWithReuseIdentifier:@"MHMediaPreviewCollectionViewCell"];
    
    cell.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [cell.collectionView setShowsHorizontalScrollIndicator:NO];
    [cell.collectionView setDelegate:self];
    [cell.collectionView setDataSource:self];
    [cell.collectionView setTag:indexPath.section];
    [cell.collectionView reloadData];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =nil;
    NSString *cellIdentifier = @"MHMediaPreviewCollectionViewCell";
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:indexPath.row inSection:collectionView.tag];
    [self makeOverViewDetailCell:(MHMediaPreviewCollectionViewCell*)cell atIndexPath:indexPathNew];
    
    return cell;
}

- (MHUICustomization *)galleryViewControllerUICustomization {
    MHUICustomization *customization = [[MHUICustomization alloc] init];
    UIColor *blackColor = [UIColor blackColor];
    [customization setMHGalleryBackgroundColor:blackColor
                                   forViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
    [customization setMHGalleryBackgroundColor:blackColor
                                   forViewMode:MHGalleryViewModeImageViewerNavigationBarHidden];
    customization.barButtonsTintColor = [UIColor whiteColor];
    customization.showOverView = NO;
    customization.hideShare = NO;
    customization.showArrows = NO;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                 NSForegroundColorAttributeName:[UIColor whiteColor]};
    customization.attributedBackButtonTitle = [[NSAttributedString alloc] initWithString:@"FEED"
                                                                              attributes:attributes]; // ;
    customization.barTintColor = [UIColor colorWithRed:0.055 green:0.059 blue:0.063 alpha:0.4];
    customization.barStyle = UIBarStyleBlack;
    return customization;
}

- (MHGalleryController *)galleryViewController {
    MHGalleryController *galleryViewController = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
    galleryViewController.UICustomization = [self galleryViewControllerUICustomization];
    galleryViewController.preferredStatusBarStyleMH = UIStatusBarStyleLightContent;
    return galleryViewController;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MHGalleryController *galleryViewController = [self galleryViewController];
    NSArray *galleryData = self.galleryDataSource[collectionView.tag];
    galleryViewController.galleryItems = galleryData;
    MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [cell thumbnail];
    galleryViewController.presentingFromImageView = imageView;
    galleryViewController.presentationIndex = indexPath.row;
    
    __weak MHGalleryController *blockGallery = galleryViewController;
    [galleryViewController setFinishedCallback:^(NSInteger currentIndex,
                                                 UIImage *image,
                                                 MHGalleryDismissTransition *interactiveTransition,
                                                 MHGalleryViewMode viewMode) {
        if (viewMode == MHGalleryViewModeOverView) {
            [blockGallery dismissViewControllerAnimated:YES
                                             completion:^{
                                                 [self setNeedsStatusBarAppearanceUpdate];
                                             }];
        }
        else {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
            CGRect cellFrame = [[collectionView collectionViewLayout] layoutAttributesForItemAtIndexPath:newIndexPath].frame;
            [collectionView scrollRectToVisible:cellFrame
                                       animated:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
                [collectionView scrollToItemAtIndexPath:newIndexPath
                                       atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                MHMediaPreviewCollectionViewCell *newCell = (MHMediaPreviewCollectionViewCell *)[collectionView cellForItemAtIndexPath:newIndexPath];
                [blockGallery dismissViewControllerAnimated:YES
                                           dismissImageView:newCell.thumbnail
                                                 completion:^{
                                                     [self setNeedsStatusBarAppearanceUpdate];
                                                     MPMoviePlayerController *player = interactiveTransition.moviePlayer;
                                                     player.controlStyle = MPMovieControlStyleEmbedded;
                                                     player.view.frame = newCell.bounds;
                                                     player.scalingMode = MPMovieScalingModeAspectFill;
                                                     [cell.contentView addSubview:player.view];
                                                 }];
            });
        }
    }];
    [self presentMHGalleryController:galleryViewController animated:YES completion:nil];
}

- (NSInteger)numberOfItemsInGallery:(MHGalleryController *)galleryController {
    return 10;
}

- (BOOL)galleryController:(MHGalleryController *)galleryController
          shouldHandleURL:(NSURL *)URL {
    return YES;
}

- (MHGalleryItem *)itemForIndex:(NSInteger)index {
    // You also have to set the image in the Testcell to get the correct Animation
    // return [MHGalleryItem.alloc initWithImage:nil];
    return [MHGalleryItem itemWithImage:MHGalleryImage(@"twitterMH")];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)makeOverViewDetailCell:(MHMediaPreviewCollectionViewCell *)cell
                   atIndexPath:(NSIndexPath*)indexPath {
    MHGalleryItem *item = self.galleryDataSource[indexPath.section][indexPath.row];
    cell.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    
    cell.thumbnail.image = nil;
    cell.galleryItem = item;
}

@end
