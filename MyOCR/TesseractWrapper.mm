//
//  TesseractWrapper.m
//  MyOCRFixed
//
//  Created by Ruxandra Nistor on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "baseapi.h"
#import <QuartzCore/QuartzCore.h>
#include "environ.h"
#import "pix.h"
#import "TesseractWrapper.h"


@implementation TesseractWrapper
@synthesize language;

// sets the language and inits Tesseract
- (TesseractWrapper *) initWithLanguage:(Language) lang {
	self = [super init];
	if(self) { 
		 self.language = lang;
		[self initTesseract];
		}
	return self;
}

//inits Tesseract
- (void) initTesseract {
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *dataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:dataPath]) {
		
		// get the path to the app bundle (with the tessdata dir)
		NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
		if (tessdataPath) {
			[fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
		}
		
	}
	
	setenv("TESSDATA_PREFIX", [[bundlePath stringByAppendingString:@"/"] UTF8String], 1);
	
	// init the tesseract engine.
	tesseract = new tesseract::TessBaseAPI();
	Language l = self.language;
	switch (l) {
		case kEng:
			tesseract->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding], "eng");
			NSLog(@"ENGLISH");
			break;
		case kRon:
			tesseract->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding], "ron");
			NSLog(@"RON");
			break;	
		case kEng2:
			tesseract->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding], "trn");
			NSLog(@"TRN");
			break;	
		default:
			tesseract->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding], "eng");
			NSLog(@"TRAINED");
			
			break;
	}
	dataPath = nil;
	bundlePath = nil;
	dataPath = nil;
}

// receive the image and start the recognition
- (NSString *) recognizeImage: (UIImage *) image
{
	[self setTesseractImage:image];
    tesseract->Recognize(NULL);
    char* utf8Text = tesseract->GetUTF8Text();
	return [NSString stringWithUTF8String:utf8Text];
}

// brings the image to a format in which tesseract can recognize
- (void)setTesseractImage:(UIImage *)image1
{
    free(pixels);
    
    CGSize size = [image1 size];
    int width = size.width;
    int height = size.height;
	
	if (width <= 0 || height <= 0)
		return;
	
    // the pixels will be painted to this array
    pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image1 CGImage]);
	
	// we're done with the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    tesseract->SetImage((const unsigned char *) pixels, width, height, sizeof(uint32_t), width * sizeof(uint32_t));
}

// this method allows changing the language of Tesseract
- (void) changeLanguage: (Language) lang {
	if(self.language != lang) {
		delete tesseract;
		tesseract = nil;
		self.language = lang;
		[self initTesseract];
	}
}


@end
