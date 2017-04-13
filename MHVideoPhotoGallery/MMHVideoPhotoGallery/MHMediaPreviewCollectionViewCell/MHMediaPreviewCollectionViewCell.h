//
//  MHGalleryCells.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHGalleryItem;

typedef void (^MHMediaPreviewCollectionViewCellShouldSaveBlock)(BOOL shouldSave);

@interface MHMediaPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIImageView *thumbnail;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UILabel *videoDurationLength;
@property (nonatomic) UIImageView *videoIcon;
@property (nonatomic) UIView *videoGradient;
@property (nonatomic) UIImageView *selectionImageView;
@property (nonatomic) MHGalleryItem *galleryItem;

@property (nonatomic, copy) MHMediaPreviewCollectionViewCellShouldSaveBlock saveImageBlock;

@end
