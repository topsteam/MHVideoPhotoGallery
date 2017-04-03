//
//  MHUICustomization.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 04.03.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGradientView.h"

typedef NS_ENUM(NSUInteger, MHGalleryViewMode) {
    MHGalleryViewModeImageViewerNavigationBarHidden = 0,
    MHGalleryViewModeImageViewerNavigationBarShown = 1,
    MHGalleryViewModeOverView = 2
};

typedef NS_ENUM(NSUInteger, MHBackButtonState) {
    MHBackButtonStateWithBackArrow,
    MHBackButtonStateWithoutBackArrow
};

@interface MHUICustomization : NSObject

@property (nonatomic) NSDictionary *descriptionLinkAttributes;
@property (nonatomic) NSDictionary *descriptionActiveLinkAttributes;
@property (nonatomic) NSAttributedString *descriptionTruncationString;
@property (nonatomic, strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutLandscape;
@property (nonatomic, strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutPortrait;
/**
 Default nil
 */
@property (nonatomic) NSString *backButtonTitle;
/**
 Default UIBarStyleDefault
 */
@property (nonatomic) UIBarStyle barStyle;
/**
 Default nil
 */
@property (nonatomic) UIColor *barTintColor;
/**
 Default nil
 */
@property (nonatomic) UIColor *barButtonsTintColor;
/**
 Default [UIColor blackColor]
 */
@property (nonatomic) UIColor *videoProgressTintColor;
/**
 Default YES
 */
@property (nonatomic) BOOL showMHShareViewInsteadOfActivityViewController;
/**
 Default NO
 */
@property (nonatomic) BOOL hideShare;
/**
 Default YES
 */
@property (nonatomic) BOOL useCustomBackButtonImageOnImageViewer;
/**
 Default YES
 */
@property (nonatomic) BOOL showOverView;
/**
 Default YES
 */
@property (nonatomic) BOOL showArrows;
/**
 Default MHBackButtonStateWithBackArrow
 */
@property (nonatomic) MHBackButtonState backButtonState;
/**
 Optional UIBarButtonItem displayed in the lower right corner. Default nil
 */
@property (nonatomic) UIBarButtonItem *customBarButtonItem;


- (void)setMHGradients:(NSArray<UIColor *> *)colors
          forDirection:(MHGradientDirection)direction;
- (NSArray<UIColor *> *)MHGradientColorsForDirection:(MHGradientDirection)direction;

- (void)setMHGalleryBackgroundColor:(UIColor *)color
                       forViewMode:(MHGalleryViewMode)viewMode;
- (UIColor *)MHGalleryBackgroundColorForViewMode:(MHGalleryViewMode)viewMode;

@end
