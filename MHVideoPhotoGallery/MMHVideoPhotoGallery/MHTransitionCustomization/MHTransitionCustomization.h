//
//  MHTransitionCustomization.h
//  MHVideoPhotoGallery
//
//  Created by tstepanov on 31.03.17.
//  Copyright © 2017 Mario Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHTransitionCustomization : NSObject

@property (nonatomic) BOOL interactiveDismiss; //Default YES
@property (nonatomic) BOOL dismissWithScrollGestureOnFirstAndLastImage;//Default YES
@property (nonatomic) BOOL fixXValueForDismiss; //Default NO

@end
