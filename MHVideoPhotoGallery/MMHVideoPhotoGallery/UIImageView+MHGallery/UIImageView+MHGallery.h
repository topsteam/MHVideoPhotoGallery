//
//  UIImageView+MHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 06.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHGalleryItem;

typedef NS_ENUM(NSUInteger, MHImageType) {
    MHImageTypeThumb = 0,
    MHImageTypeFull = 1,
};

typedef void (^MHVideoThumbnailCompletionBlock)(UIImage *image, NSUInteger videoDuration, NSError *error);
typedef void (^MHImageSetupCompletionBlock)(UIImage *image, NSError *error);

@interface UIImageView (MHGallery)

- (void)setImageForMHGalleryItem:(MHGalleryItem *)item
                       imageType:(MHImageType)imageType
                         success:(MHImageSetupCompletionBlock)success;
@end
