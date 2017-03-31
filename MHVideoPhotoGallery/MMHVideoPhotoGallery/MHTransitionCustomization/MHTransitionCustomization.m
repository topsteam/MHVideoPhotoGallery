//
//  MHTransitionCustomization.m
//  MHVideoPhotoGallery
//
//  Created by tstepanov on 31.03.17.
//  Copyright © 2017 Mario Hahn. All rights reserved.
//

#import "MHTransitionCustomization.h"

@implementation MHTransitionCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.interactiveDismiss = YES;
        self.dismissWithScrollGestureOnFirstAndLastImage = YES;
        self.fixXValueForDismiss = NO;
    }
    return self;
}

@end
