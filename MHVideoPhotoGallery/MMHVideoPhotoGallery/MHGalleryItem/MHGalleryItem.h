//
//  MHGalleryItem.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHGallery.h"

typedef NS_ENUM(NSUInteger, MHGalleryType) {
    MHGalleryTypeImage,
    MHGalleryTypeVideo
};

@interface MHGalleryItem : NSObject

@property (nonatomic) NSURL *URL;
/**
 Thumb images are automatically generated for Videos.
 But you can set Thumb Images for GalleryTypeImage.
 */
@property (nonatomic) NSURL *thumbnailURL;

@property (nonatomic) MHGalleryType galleryType;

@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *thumbnailImage;

@property (nonatomic) NSString *titleString;
@property (nonatomic) NSAttributedString *attributedTitle;
@property (nonatomic) NSString *descriptionString;
@property (nonatomic) NSAttributedString *attributedString;

+ (instancetype)itemWithURL:(NSURL *)URL
               thumbnailURL:(NSURL *)thumbnailURL;
/**
 @param URL the URL of the image or Video as a String
 @param galleryType select to Type, video or image
 */
+ (instancetype)itemWithURL:(NSURL *)URL
                galleryType:(MHGalleryType)galleryType;

/**
 MHGalleryItem itemWithYoutubeVideoID:
 @param ID  Example: http://www.youtube.com/watch?v=YSdJtNen-EA - YSdJtNen-EA is the ID
 */
+ (instancetype)itemWithYoutubeVideoID:(NSString *)ID;

/**
 MHGalleryItem itemWithVimeoVideoID:
 @param ID Example: http://vimeo.com/35515926 - 35515926 is the ID
 */
+ (instancetype)itemWithVimeoVideoID:(NSString *)ID;

/**
 MHGalleryItem initWithImage
 @param image to Display
 */
+ (instancetype)itemWithImage:(UIImage *)image;

@end
