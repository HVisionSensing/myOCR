//
//  UIImage+processing.h
//  MyOCRFixed
//
//  Created by Ruxandra Nistor on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (processing)
- (UIImage *)fixOrientation;
- (UIImage *) threshold;
- (UIImage *) resize;
- (UIImage *) makeThumbnail;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *) rotate:(CGFloat) f;
@end
