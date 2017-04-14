//
//  MHGalleryItem.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGalleryItem.h"

@implementation MHGalleryItem

+ (instancetype)itemWithImage:(UIImage *)image {
    return [self.class.alloc initWithImage:image];
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.galleryType = MHGalleryTypeImage;
        self.image = image;
    }
    return self;
}

+ (instancetype)itemWithVimeoVideoID:(NSString *)ID {
    return [[self.class alloc] initWithURL:[NSString stringWithFormat:MHVimeoBaseURL, ID]
                               galleryType:MHGalleryTypeVideo];
}

+ (instancetype)itemWithYoutubeVideoID:(NSString *)ID {
    return [[self.class alloc] initWithURL:[NSString stringWithFormat:MHYoutubeBaseURL, ID]
                               galleryType:MHGalleryTypeVideo];
}

+ (instancetype)itemWithURL:(NSString *)URLString
                galleryType:(MHGalleryType)galleryType {
    return [[self.class alloc] initWithURL:URLString
                               galleryType:galleryType];
}

- (instancetype)initWithURL:(NSString *)URLString
                galleryType:(MHGalleryType)galleryType {
    self = [super init];
    if (self) {
        self.URLString = URLString;
        self.thumbnailURLString = URLString;
        self.titleString = nil;
        self.attributedTitle = nil;
        self.descriptionString = nil;
        self.galleryType = galleryType;
        self.attributedString = nil;
        self.thumbnailImage = nil;
    }
    return self;
}

+ (instancetype)itemWithURL:(NSString *)URLString
               thumbnailURL:(NSString *)thumbnailURLString {
    return [[self.class alloc] initWithURL:URLString
                              thumbnailURL:thumbnailURLString];
}

- (instancetype)initWithURL:(NSString *)URLString
               thumbnailURL:(NSString *)thumbnailURLString {
    self = [super init];
    if (self) {
        self.URLString = URLString;
        self.thumbnailURLString = thumbnailURLString;
        self.attributedTitle = nil;
        self.descriptionString = nil;
        self.descriptionString = nil;
        self.galleryType = MHGalleryTypeImage;
        self.attributedString = nil;
        self.thumbnailImage = nil;
    }
    return self;
}

@end
