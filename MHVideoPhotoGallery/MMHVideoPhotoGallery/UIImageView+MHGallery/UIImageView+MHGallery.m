//
//  UIImageView+MHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 06.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "UIImageView+MHGallery.h"
#import "MHGallery.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (MHGallery)

- (void)setImageForMHGalleryItem:(MHGalleryItem *)item
                       imageType:(MHImageType)imageType
                         success:(MHImageSetupCompletionBlock)success {
    __weak typeof(self) weakSelf = self;
    BOOL isLocalImage = [item.URL.absoluteString rangeOfString:MHAssetLibrary].location != NSNotFound;
    if (item.image) {
        [self setImageForImageView:item.image
                           success:success];
    }
    else if (isLocalImage && item.URL) {
        MHAssetImageType assetType = (MHAssetImageType)imageType;
        [[MHGallerySharedManager sharedManager] getImageFromAssetLibraryWithURL:item.URL assetType:assetType success:^(UIImage *image, NSError *error) {
            [weakSelf setImageForImageView:image success:success];
        }];
    }
    else {
        UIImage *placeholderImage = [self thumbnailImageForItem:item];
        [self sd_setImageWithURL:item.URL placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (success) {
                success(image, error);
            }
        }];
    }
}

#pragma mark - Private methods

- (void)setImageForImageView:(UIImage *)image
                     success:(MHImageSetupCompletionBlock)success {
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(),^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.image = image;
        [strongSelf setNeedsLayout];
        if (success) {
            success(image, nil);
        }
    });
}

- (UIImage *)thumbnailImageForItem:(MHGalleryItem *)item {
    UIImage *thumbnailImage;
    if (item.thumbnailImage) {
        thumbnailImage = item.thumbnailImage;
    }
    else {
        NSString *thumbnailKey = [[SDWebImageManager sharedManager] cacheKeyForURL:item.thumbnailURL];
        thumbnailImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:thumbnailKey];
    }
    return thumbnailImage;
}

@end
