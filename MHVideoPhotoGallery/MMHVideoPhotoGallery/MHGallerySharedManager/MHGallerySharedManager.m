//
//  MHGallerySharedManager.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGallerySharedManager.h"
#import "MHGallerySharedManagerPrivate.h"
#import "SDWebImageManager.h"

@implementation MHGallerySharedManager

+ (MHGallerySharedManager *)sharedManager {
    static MHGallerySharedManager *sharedManagerInstance = nil;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedManagerInstance = self.new;
    });
    return sharedManagerInstance;
}

- (void)startDownloadingThumbImageURL:(NSURL *)URL
                              success:(MHImageVideoDurationErrorCompletionBlock)success {
    [self startDownloadingThumbImage:URL.absoluteString success:success];
}

- (void)startDownloadingThumbImage:(NSString*)urlString
                           success:(MHImageVideoDurationErrorCompletionBlock)success {
    
    BOOL isVimeoVideo = [urlString rangeOfString:@"vimeo.com"].location != NSNotFound;
    BOOL isYouTubeVideo = [urlString rangeOfString:@"youtube.com"].location != NSNotFound;
    
    if (isVimeoVideo) {
        [self getVimdeoThumbImage:urlString
                          success:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                              success(image, videoDuration, error);
                          }];
    }
    else if (isYouTubeVideo) {
        [self getYoutubeThumbImage:urlString
                           success:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                               success(image,videoDuration,error);
                           }];
    }
    else {
        [self createThumbURL:urlString
                     success:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                         success(image,videoDuration,error);
                     }];
    }
}

- (void)getURLForMediaPlayerWithURL:(NSURL *)URL
                            success:(MHURLErrorCompletionBlock)success {
    [self getURLForMediaPlayer:URL.absoluteString success:success];
}

- (void)getURLForMediaPlayer:(NSString *)URLString
                     success:(MHURLErrorCompletionBlock)success {
    if ([URLString rangeOfString:@"vimeo.com"].location != NSNotFound) {
        [self getVimeoURLforMediaPlayer:URLString success:^(NSURL *URL, NSError *error) {
            success(URL,error);
        }];
    }
    else if ([URLString rangeOfString:@"youtube.com"].location != NSNotFound) {
        [self getYoutubeURLforMediaPlayer:URLString success:^(NSURL *URL, NSError *error) {
            success(URL,error);
        }];
    }
    else {
        success([NSURL URLWithString:URLString],nil);
    }
}

- (void)getYoutubeURLforMediaPlayer:(NSString *)URL
                            success:(MHURLErrorCompletionBlock)success {
    
    NSString *videoID = [[URL componentsSeparatedByString:@"?v="] lastObject];
    NSURL *videoInfoURL = [NSURL URLWithString:[NSString stringWithFormat:MHYoutubePlayBaseURL, videoID ?: @"", [self languageIdentifier]]];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:videoInfoURL
                                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                timeoutInterval:10];
    [httpRequest setValue:[self languageIdentifier] forHTTPHeaderField:@"Accept-Language"];
    [NSURLConnection sendAsynchronousRequest:httpRequest
                                       queue:NSOperationQueue.new
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               dispatch_async(dispatch_get_main_queue(), ^(void) {
                                   NSURL *playURL = [self getYoutubeURLWithData:data];
                                   if (playURL) {
                                       success(playURL,nil);
                                   }else{
                                       success(nil,nil);
                                   }
                               });
                           }];
}

- (void)getVimeoURLforMediaPlayer:(NSString *)URL
                          success:(MHURLErrorCompletionBlock)success {
    
    NSString *videoID = [[URL componentsSeparatedByString:@"/"] lastObject];
    NSURL *vimdeoURL= [NSURL URLWithString:[NSString stringWithFormat:MHVimeoVideoBaseURL, videoID]];
    
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:vimdeoURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:10];
    
    [httpRequest setValue:@"application/json"
       forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:httpRequest queue:NSOperationQueue.new completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error;
            
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&error];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSDictionary *filesInfo = [jsonData valueForKeyPath:@"request.files.h264"];
                if (!filesInfo) {
                    success(nil,nil);
                }
                NSString *quality = NSString.new;
                if (self.vimeoVideoQuality == MHVimeoVideoQualityHD) {
                    quality = @"hd";
                    if (!filesInfo[quality]) {
                        quality = @"sd";
                    }
                }
                else if (self.vimeoVideoQuality == MHVimeoVideoQualityMobile) {
                    quality = @"mobile";
                }
                else if (self.vimeoVideoQuality == MHVimeoVideoQualitySD) {
                    quality = @"sd";
                }
                NSDictionary *videoInfo =filesInfo[quality];
                if (!videoInfo[@"url"]) {
                    success(nil,nil);
                }
                success([NSURL URLWithString:videoInfo[@"url"]],nil);
            });
        }
        else {
            success(nil,connectionError);
        }
        
    }];
}


- (void)getImageFromAssetLibraryWithURL:(NSURL *)URL
                              assetType:(MHAssetImageType)type
                                success:(MHImageErrorCompletionBlock)success {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        ALAssetsLibrary *assetslibrary = ALAssetsLibrary.new;
        [assetslibrary assetForURL:URL resultBlock:^(ALAsset *asset) {
            
            if (type == MHAssetImageTypeThumb) {
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    UIImage *image = [UIImage.alloc initWithCGImage:asset.thumbnail];
                    success(image,nil);
                });
            }
            else {
                ALAssetRepresentation *rep = asset.defaultRepresentation;
                CGImageRef iref = rep.fullScreenImage;
                if (iref) {
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        UIImage *image = [UIImage.alloc initWithCGImage:iref];
                        success(image,nil);
                    });
                }
            }
        } failureBlock:^(NSError *error) {
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                success(nil, error);
            });
        }];
    });
}

- (void)getMHGalleryObjectsForYoutubeChannel:(NSString *)channelName
                                   withTitle:(BOOL)withTitle
                                     success:(MHGalleryObjectsErrorCompletionBlock)success {
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:MHYoutubeChannel,channelName]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:httpRequest queue:NSOperationQueue.new completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            success(nil,connectionError);
        }
        else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                NSError *error = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
                if (!error) {
                    NSMutableArray *galleryData = NSMutableArray.new;
                    for (NSDictionary *dictionary in dict[@"feed"][@"entry"]) {
                        NSString *string = [dictionary[@"link"] firstObject][@"href"];
                        
                        string = [string stringByReplacingOccurrencesOfString:@"&feature=youtube_gdata" withString:@""];
                        NSURL *url = [NSURL URLWithString:string];
                        MHGalleryItem *item = [MHGalleryItem itemWithURL:url
                                                             galleryType:MHGalleryTypeVideo];
                        if (withTitle) {
                            item.descriptionString = dictionary[@"title"][@"$t"];
                        }
                        [galleryData addObject:item];
                    }
                    success(galleryData,nil);
                }else{
                    success(nil,error);
                }
            });
        }
    }];
}

- (BOOL)isUIViewControllerBasedStatusBarAppearance {
    NSNumber *isUIVCBasedStatusBarAppearance = [NSBundle.mainBundle objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isUIVCBasedStatusBarAppearance) {
        return  isUIVCBasedStatusBarAppearance.boolValue;
    }
    return YES;
}

#pragma mark - Private functions

- (NSString *)languageIdentifier {
    static NSString *applicationLanguageIdentifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        applicationLanguageIdentifier = @"en";
        NSArray *preferredLocalizations = NSBundle.mainBundle.preferredLocalizations;
        if (preferredLocalizations.count > 0)
            applicationLanguageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:preferredLocalizations[0]] ?: applicationLanguageIdentifier;
    });
    return applicationLanguageIdentifier;
}

- (NSURL *)getYoutubeURLWithData:(NSData *)data {
    NSString *videoData = [NSString.alloc initWithData:data encoding:NSASCIIStringEncoding];
    
    NSDictionary *video = MHDictionaryForQueryString(videoData);
    NSArray *videoURLS = [video[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","];
    NSMutableDictionary *streamURLs = NSMutableDictionary.new;
    for (NSString *videoURL in videoURLS) {
        NSDictionary *stream = MHDictionaryForQueryString(videoURL);
        NSString *typeString = stream[@"type"];
        NSString *urlString = stream[@"url"];
        if (urlString && [AVURLAsset isPlayableExtendedMIMEType:typeString]) {
            NSURL *streamURL = [NSURL URLWithString:urlString];
            NSString *sig = stream[@"sig"];
            if (sig) {
                streamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&signature=%@", urlString, sig]];
            }
            if ([[MHDictionaryForQueryString(streamURL.query) allKeys] containsObject:@"signature"]) {
                streamURLs[@([stream[@"itag"] integerValue])] = streamURL;
            }
        }
    }
    if (self.youtubeVideoQuality == MHYoutubeVideoQualityHD720) {
        if (streamURLs[@(22)]) {
            return streamURLs[@(22)];
        }
    }
    
    if (self.youtubeVideoQuality == MHYoutubeVideoQualityHD720 || self.youtubeVideoQuality == MHYoutubeVideoQualityMedium) {
        if (streamURLs[@(18)]) {
            return streamURLs[@(18)];
        }
    }
    if (self.youtubeVideoQuality == MHYoutubeVideoQualitySmall) {
        if (streamURLs[@(36)]) {
            return streamURLs[@(36)];
        }
    }
    
    return nil;
}

- (void)setObjectToUserDefaults:(NSMutableDictionary *)dict {
    [NSUserDefaults.standardUserDefaults setObject:dict forKey:MHGalleryDurationData];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSMutableDictionary *)durationDict {
    return [NSMutableDictionary.alloc initWithDictionary:[NSUserDefaults.standardUserDefaults objectForKey:MHGalleryDurationData]];
}

- (void)getYoutubeThumbImage:(NSString *)URLString
                     success:(MHImageVideoDurationErrorCompletionBlock)success {
    NSString *thumbnailImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:URLString]];
    UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:thumbnailImageKey];
    if (thumbnailImage) {
        NSMutableDictionary *dict = [self durationDict];
        success(thumbnailImage, [dict[URLString] integerValue],nil);
    }
    else {
        NSString *videoID = [[URLString componentsSeparatedByString:@"?v="] lastObject];
        NSString *infoURL = [NSString stringWithFormat:MHYoutubeInfoBaseURL,videoID];
        NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:infoURL]
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10];
        
        [NSURLConnection sendAsynchronousRequest:httpRequest queue:NSOperationQueue.new completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSError *error;
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&error];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (jsonData.count) {
                        NSMutableDictionary *dictToSave = [self durationDict];
                        dictToSave[URLString] = @([jsonData[@"data"][@"duration"] integerValue]);
                        
                        [self setObjectToUserDefaults:dictToSave];
                        NSString *thumbURLString = [NSString string];
                        
                        if (self.youtubeThumbQuality == MHYoutubeThumbQualityHQ) {
                            thumbURLString = jsonData[@"data"][@"thumbnail"][@"hqDefault"];
                        }
                        else if (self.youtubeThumbQuality == MHYoutubeThumbQualitySQ) {
                            thumbURLString = jsonData[@"data"][@"thumbnail"][@"sqDefault"];
                        }
                        
                        NSURL *thumbURL = [NSURL URLWithString:thumbURLString];
                        [SDWebImageManager.sharedManager loadImageWithURL:thumbURL options:SDWebImageContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                            
                            [SDImageCache.sharedImageCache removeImageForKey:thumbnailImageKey withCompletion:nil];
                            [SDImageCache.sharedImageCache storeImage:image
                                                               forKey:thumbnailImageKey completion:nil];
                            NSInteger videoDuration = [jsonData[@"data"][@"duration"] integerValue];
                            success(image, videoDuration, nil);
                        }];
                    }
                });
            }
            else{
                success(nil, 0, connectionError);
            }
        }];
    }
    
}

- (void)getVimdeoThumbImage:(NSString*)URL
                    success:(MHImageVideoDurationErrorCompletionBlock)success {
    
    NSString *videoID = [[URL componentsSeparatedByString:@"/"] lastObject];
    NSString *vimeoURLString = [NSString stringWithFormat:MHVimeoThumbBaseURL, videoID];
    NSURL *vimeoURL = [NSURL URLWithString:vimeoURLString];
    
    NSString *thumbnailImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:vimeoURL];
    UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:thumbnailImageKey];
    if (thumbnailImage) {
        NSMutableDictionary *dict = [self durationDict];
        NSInteger videoDuration = [dict[vimeoURLString] integerValue];
        success(thumbnailImage, videoDuration, nil);
    }
    else {
        NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:vimeoURL
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10];
        [NSURLConnection sendAsynchronousRequest:httpRequest queue:NSOperationQueue.new completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                success(nil, 0, connectionError);
            }
            else {
                NSError *error;
                NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];
                dispatch_async(dispatch_get_main_queue(), ^() {
                    if (jsonData.count) {
                        NSString *quality = NSString.new;
                        if (self.vimeoThumbQuality == MHVimeoThumbQualityLarge) {
                            quality = @"thumbnail_large";
                        }
                        else if (self.vimeoThumbQuality == MHVimeoThumbQualityMedium) {
                            quality = @"thumbnail_medium";
                        }
                        else if (self.vimeoThumbQuality == MHVimeoThumbQualitySmall) {
                            quality = @"thumbnail_small";
                        }
                        
                        if ([jsonData firstObject][quality]) {
                            NSMutableDictionary *dictToSave = [self durationDict];
                            NSInteger videoDuration = [jsonData[0][@"duration"] integerValue];
                            dictToSave[vimeoURLString] = @(videoDuration);
                            [self setObjectToUserDefaults:dictToSave];
                            
                            NSString *imageURLStirng = jsonData[0][quality];
                            NSURL *imageURL = [NSURL URLWithString:imageURLStirng];
                            [SDWebImageManager.sharedManager loadImageWithURL:imageURL options:SDWebImageContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                [[SDImageCache sharedImageCache] removeImageForKey:imageURLStirng withCompletion:^{
                                    [SDImageCache.sharedImageCache storeImage:image
                                                                       forKey:vimeoURLString
                                                                   completion:nil];
                                }];
                                success(image, videoDuration, nil);
                            }];
                        }
                        else {
                            success(nil, 0, nil);
                        }
                        
                    }
                    else {
                        success(nil, 0, nil);
                    }
                });
            }
        }];
    }
}

- (void)createThumbURL:(NSString *)urlString
               success:(MHImageVideoDurationErrorCompletionBlock)success {
    
    NSString *thumbnailImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:urlString]];
    UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:thumbnailImageKey];

    NSMutableDictionary *dict = [self durationDict];
    if (!dict) {
        dict = NSMutableDictionary.new;
    }
    
    if (thumbnailImage) {
        success(thumbnailImage, [dict[urlString] integerValue], nil);
    }
    else {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSURL *url = [NSURL URLWithString:urlString];
            AVURLAsset *asset = [AVURLAsset.alloc  initWithURL:url options:nil];
            
            AVAssetImageGenerator *generator = [AVAssetImageGenerator.alloc initWithAsset:asset];
            generator.appliesPreferredTrackTransform = YES;
            CMTime thumbTime = CMTimeMakeWithSeconds(0,40);
            CMTime videoDurationTime = asset.duration;
            NSUInteger videoDurationTimeInSeconds = CMTimeGetSeconds(videoDurationTime);
            
            NSMutableDictionary *dictToSave = [self durationDict];
            if (videoDurationTimeInSeconds !=0) {
                dictToSave[urlString] = @(videoDurationTimeInSeconds);
                [self setObjectToUserDefaults:dictToSave];
            }
            
            if (self.webPointForThumb == MHWebPointForThumbStart) {
                thumbTime = CMTimeMakeWithSeconds(0,40);
            }
            else if (self.webPointForThumb == MHWebPointForThumbMiddle) {
                thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds/2,40);
            }
            else if (self.webPointForThumb == MHWebPointForThumbEnd) {
                thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds,40);
            }
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                
                if (result != AVAssetImageGeneratorSucceeded || im == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        success(nil,0,error);
                    });
                }
                else {
                    UIImage *image = [UIImage imageWithCGImage:im];
                    if (image != nil) {
                        [SDImageCache.sharedImageCache storeImage:image forKey:urlString completion:nil];
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            success(image, videoDurationTimeInSeconds, nil);
                        });
                    }
                }
            };
            if (self.webThumbQuality == MHWebThumbQualityHD720) {
                generator.maximumSize = CGSizeMake(720, 720);
            }
            else if (self.webThumbQuality == MHWebThumbQualityMedium) {
                generator.maximumSize = CGSizeMake(420 ,420);
            }
            else if (self.webThumbQuality == MHWebThumbQualitySmall) {
                generator.maximumSize = CGSizeMake(220 ,220);
            }
            [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:thumbTime]]
                                            completionHandler:handler];
        });
    }
}

+ (NSString *)stringForMinutesAndSeconds:(NSInteger)seconds
                                addMinus:(BOOL)addMinus {
    
    NSNumber *minutesNumber = @(seconds / 60);
    NSNumber *secondsNumber = @(seconds % 60);
    
    NSString *string = [NSString stringWithFormat:@"%@:%@",[MHNumberFormatterVideo() stringFromNumber:minutesNumber],[MHNumberFormatterVideo() stringFromNumber:secondsNumber]];
    if (addMinus) {
        return [NSString stringWithFormat:@"-%@",string];
    }
    return string;
}

@end
