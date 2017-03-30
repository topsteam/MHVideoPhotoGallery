//
//  MHBarButtonItem.h
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 09/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, MHBarButtonItemType) {
    MHBarButtonItemTypeLeft,
    MHBarButtonItemTypeRight,
    MHBarButtonItemTypePlayPause,
    MHBarButtonItemTypeShare,
    MHBarButtonItemTypeFlexible,
    MHBarButtonItemTypeFixed,
    MHBarButtonItemTypeCustom
};

@interface MHBarButtonItem : UIBarButtonItem

@property (nonatomic) MHBarButtonItemType type;

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem
                                     target:(id)target
                                       type:(MHBarButtonItemType)type
                                     action:(SEL)action;

- (instancetype)initWithImage:(UIImage *)image
                        style:(UIBarButtonItemStyle)style
                       target:(id)target
                         type:(MHBarButtonItemType)type
                       action:(SEL)action;

@end
