//
//  MHGallerySharedManager.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHGallery.h"

typedef void (^MHImageErrorCompletionBlock)(UIImage *image, NSError *error);
typedef void (^MHImageVideoDurationErrorCompletionBlock)(UIImage *image, NSUInteger videoDuration, NSError *error);
typedef void (^MHURLErrorCompletionBlock)(NSURL *URL, NSError *error);
typedef void (^MHGalleryObjectsErrorCompletionBlock)(NSArray<MHGalleryItem *> *MHGalleryObjects,NSError *error);

typedef NS_ENUM(NSUInteger, MHAssetImageType) {
    MHAssetImageTypeFull = 0,
    MHAssetImageTypeThumb = 1,
};

typedef NS_ENUM(NSUInteger, MHWebPointForThumb) {
    MHWebPointForThumbStart, // Default
    MHWebPointForThumbMiddle, // videoDuration/2
    MHWebPointForThumbEnd //videoDuration
};

typedef NS_ENUM(NSUInteger, MHYoutubeVideoQuality) {
    MHYoutubeVideoQualityHD720, //Default
    MHYoutubeVideoQualityMedium,
    MHYoutubeVideoQualitySmall
};

typedef NS_ENUM(NSUInteger, MHVimeoVideoQuality) {
    MHVimeoVideoQualityHD, //Default
    MHVimeoVideoQualityMobile,
    MHVimeoVideoQualitySD
};

typedef NS_ENUM(NSUInteger, MHVimeoThumbQuality) {
    MHVimeoThumbQualityLarge, //Default
    MHVimeoThumbQualityMedium,
    MHVimeoThumbQualitySmall
};

typedef NS_ENUM(NSUInteger, MHWebThumbQuality) {
    MHWebThumbQualityHD720, //Default
    MHWebThumbQualityMedium,
    MHWebThumbQualitySmall
};

typedef NS_ENUM(NSUInteger, MHYoutubeThumbQuality) {
    MHYoutubeThumbQualityHQ, //Default
    MHYoutubeThumbQualitySQ
};


@interface MHGallerySharedManager : NSObject

/**
 *  default is MHYoutubeThumbQualityHQ
 */
@property (nonatomic, assign) MHYoutubeThumbQuality youtubeThumbQuality;
/**
 *  Default is MHVimeoThumbQualityLarge
 */
@property (nonatomic, assign) MHVimeoThumbQuality vimeoThumbQuality;
/**
 *  default is MHWebThumbQualityHD720
 */
@property (nonatomic, assign) MHWebThumbQuality webThumbQuality;
/**
 *  default is MHWebPointForThumbStart
 */
@property (nonatomic, assign) MHWebPointForThumb webPointForThumb;
/**
 *  default is MHVimeoVideoQualityHD
 */
@property (nonatomic, assign) MHVimeoVideoQuality vimeoVideoQuality;
/**
 *  default is MHYoutubeVideoQualityHD720
 */
@property (nonatomic, assign) MHYoutubeVideoQuality youtubeVideoQuality;

+ (MHGallerySharedManager *)sharedManager;

/**
 Method generates thumbnail image from a local video, or from videos on a Webserver, Youtube and Vimeo
 @param URL video file URL
 @param succeedBlock returns the image the duration of the video and an error
 */
- (void)startDownloadingThumbImageURL:(NSURL *)URL
                              success:(MHImageVideoDurationErrorCompletionBlock)success;


/**
 *  To get the absolute URL for Vimeo Videos. To change the Quality check vimeoVideoQuality
 *  @param URL object URL
 *  @param succeedBlock you will get the absolute URL
 */
- (void)getURLForMediaPlayerWithURL:(NSURL *)URL
                            success:(MHURLErrorCompletionBlock)success;

/**
 To get the absolute URL for Youtube Videos. To change the Quality check youtubeVideoQuality
 @param URL          The URL as a String
 @param succeedBlock you will get the absolute URL
 */
- (void)getYoutubeURLforMediaPlayer:(NSString*)URL
                            success:(MHURLErrorCompletionBlock)success;

- (void)getVimeoURLforMediaPlayer:(NSString *)URL
                          success:(MHURLErrorCompletionBlock)success;

/**
 Returns all MHGalleryObjects for a Youtube channel
 @param channelName  set the name of the channel
 @param withTitle    if you want the title of the video set it to YES
 @param succeedBlock returns the Gallery items
 */
- (void)getMHGalleryObjectsForYoutubeChannel:(NSString*)channelName
                                   withTitle:(BOOL)withTitle
                                     success:(MHGalleryObjectsErrorCompletionBlock)success;

- (BOOL)isUIViewControllerBasedStatusBarAppearance;

- (void)getImageFromAssetLibraryWithURL:(NSURL *)URL
                              assetType:(MHAssetImageType)type
                                success:(MHImageErrorCompletionBlock)success;

@end
