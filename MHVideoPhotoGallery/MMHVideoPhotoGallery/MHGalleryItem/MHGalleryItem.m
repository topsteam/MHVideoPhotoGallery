//
//  MHGalleryItem.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGalleryItem.h"

@implementation MHGalleryItem


+ (instancetype)itemWithURL:(NSURL *)URL
                galleryType:(MHGalleryType)galleryType {
    return [[self.class alloc] initWithURL:URL
                               galleryType:galleryType];
}

+ (instancetype)itemWithURL:(NSURL *)URL
               thumbnailURL:(NSURL *)thumbnailURL {
    return [[self.class alloc] initWithURL:URL
                              thumbnailURL:thumbnailURL];
}

+ (instancetype)itemWithImage:(UIImage *)image {
    return [self.class.alloc initWithImage:image];
}

+ (instancetype)itemWithVimeoVideoID:(NSString *)ID {
    NSURL *vimeoVideoURL = [NSURL URLWithString:[NSString stringWithFormat:MHVimeoBaseURL, ID]];
    return [[self.class alloc] initWithURL:vimeoVideoURL
                               galleryType:MHGalleryTypeVideo];
}

+ (instancetype)itemWithYoutubeVideoID:(NSString *)ID {
    NSURL *youTubeVideoURL = [NSURL URLWithString:[NSString stringWithFormat:MHYoutubeBaseURL, ID]];
    return [[self.class alloc] initWithURL:youTubeVideoURL
                               galleryType:MHGalleryTypeVideo];
}

#pragma mark - Private methods

- (instancetype)initWithURL:(NSURL *)URL
               thumbnailURL:(NSURL *)thumbnailURL {
    self = [super init];
    if (self) {
        self.URL = URL;
        self.thumbnailURL = thumbnailURL;
        self.galleryType = MHGalleryTypeImage;
        
        self.attributedString = nil;
        self.attributedTitle = nil;
        self.descriptionString = nil;
        self.descriptionString = nil;
        
        self.thumbnailImage = nil;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL
                galleryType:(MHGalleryType)galleryType {
    self = [super init];
    if (self) {
        self.URL = URL;
        self.thumbnailURL = URL; //this case thumbURL is the same as the whole image URL
        self.galleryType = galleryType;
        
        self.titleString = nil;
        self.attributedTitle = nil;
        self.descriptionString = nil;
        self.attributedString = nil;
        
        self.thumbnailImage = nil;
        self.image = nil;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.galleryType = MHGalleryTypeImage;
        self.image = image;
    }
    return self;
}

@end
