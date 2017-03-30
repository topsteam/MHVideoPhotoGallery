//
//  MHBarButtonItem.m
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 09/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import "MHBarButtonItem.h"

@implementation MHBarButtonItem

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem
                                     target:(id)target
                                       type:(MHBarButtonItemType)type
                                     action:(SEL)action {
    self = [super initWithBarButtonSystemItem:systemItem
                                       target:target
                                       action:action];
    if (self) {
        self.type = type;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
                        style:(UIBarButtonItemStyle)style
                       target:(id)target
                         type:(MHBarButtonItemType)type
                       action:(SEL)action {
    self = [super initWithImage:image
                          style:style
                         target:target
                         action:action];
    if (self) {
        self.type = type;
    }
    return self;
}

@end
