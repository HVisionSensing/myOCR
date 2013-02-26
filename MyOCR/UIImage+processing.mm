//
//  UIImage+processing.m
//  MyOCRFixed
//
//  Created by Ruxandra Nistor on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+processing.h"
#import "Image.h"

@implementation UIImage (processing)


- (UIImage *)fixOrientation {
	
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
	
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
	
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
			
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
	
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
			
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
	//transform = CGAffineTransformScale(transform, 1/2, 1/2);
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
			
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
	
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//applies threshold after applying gaussian blue and making the image greyscale
-(UIImage *) threshold {
	ImageWrapper *greyScale;
	greyScale=Image::createImage(self, self.size.width, self.size.height);
	ImageWrapper *threshold=greyScale.image->gaussianBlur().image->autoLocalThreshold();//;
	
	// show the results
	return threshold.image->toUIImage();
}


// resizes the image as it's too large to be processed by Tesseract
- (UIImage *)resize
{ 
	CGSize size = self.size;
	size.width = size.width /2;
	size.height = size.height /2;
	return [self resizedImage: size transform:CGAffineTransformIdentity drawTransposed:NO interpolationQuality:kCGInterpolationHigh];
}


// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}
//returns a thumbnail version of the image
-(UIImage *) makeThumbnail {
	CGSize size = self.size;
	size.width = 30;
	size.height = 30;
	return [self resizedImage: size transform:CGAffineTransformIdentity drawTransposed:NO interpolationQuality:kCGInterpolationHigh];

}

- (UIImage *) rotate:(CGFloat) f {
	
	CIImage *beginImage = [[CIImage alloc] initWithCGImage:[self CGImage]];
	CIContext *context = [CIContext contextWithOptions:nil];
	//context.outputImageMaximumSize = self.size;
	
	CIFilter *straigten = [CIFilter filterWithName:@"CIStraightenFilter"];
	[straigten setDefaults];
	[straigten setValue: beginImage forKey: kCIInputImageKey];
	[straigten setValue: [NSNumber numberWithFloat: f]
				 forKey: @"inputAngle"];
	
	CIImage *outputImage = [straigten valueForKey:kCIOutputImageKey];
	NSLog(@"%f %f", self.size.height, self.size.width);
	NSLog(@"%@", outputImage);
	
	
	CGImageRef cgimg =
	[context createCGImage:outputImage fromRect:[outputImage extent]];
	
	
	UIImage *newImg = [UIImage imageWithCGImage:cgimg];
	NSLog(@"%f %f", newImg.size.height, newImg.size.width);
	CGImageRelease(cgimg);
	return newImg;
	
}

@end
