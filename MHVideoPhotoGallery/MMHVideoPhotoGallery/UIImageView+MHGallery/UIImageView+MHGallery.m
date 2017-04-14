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

- (void)setThumbWithURL:(NSString *)URL
                success:(MHVideoThumbnailCompletionBlock)success {
    __weak typeof(self) weakSelf = self;
    [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:URL success:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setImageForImageView:image
                                 success:^(UIImage *image, NSError *error) {
                                     if (success) {
                                         success(image, videoDuration, error);
                                     }
                                 }];
    }];
}

- (void)setImageForMHGalleryItem:(MHGalleryItem *)item
                       imageType:(MHImageType)imageType
                         success:(MHImageSetupCompletionBlock)success {
    __weak typeof(self) weakSelf = self;
    BOOL isLocalImage = [item.URLString rangeOfString:MHAssetLibrary].location != NSNotFound;
    if (item.image) {
        [self setImageForImageView:item.image
                           success:success];
    }
    else if (isLocalImage && item.URLString) {
        MHAssetImageType assetType = (MHAssetImageType)imageType;
        [[MHGallerySharedManager sharedManager] getImageFromAssetLibrary:item.URLString assetType:assetType success:^(UIImage *image, NSError *error) {
            [weakSelf setImageForImageView:image success:success];
        }];
    }
    else {
        UIImage *placeholderImage = item.thumbnailImage ? : [SDImageCache.sharedImageCache imageFromDiskCacheForKey:item.thumbnailURLString];
        [self sd_setImageWithURL:[NSURL URLWithString:item.URLString] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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

@end
