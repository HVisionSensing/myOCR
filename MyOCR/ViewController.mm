//
//  ViewController.m
//  TesseractSample
//
//  Created by Ruxandra Nistor on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>
#import "SecondViewController.h"
#import "SettingsViewController.h"
#import "UIImage+processing.h"
#include "baseapi.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#include "environ.h"
#import "pix.h"
#import "UIImage+OpenCV.h"

@implementation ViewController

@synthesize progressHud;
@synthesize progressFilter;
@synthesize imageView;
@synthesize image;
@synthesize processButton;
@synthesize original;


#pragma mark - View lifecycle

//set the rotation to zero
- (void)my_init {
    if (self) {
		rotation = 0.0;
    }
}

- (void)dealloc {
//    delete tesseract;
//    tesseract = nil;
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self my_init];
	original = image;
	//adding the gesture recognizer to the view
	[self addGestureRecognizersToPiece];
	//put the image on the imageView
	[imageView setImage:image];
	processed = NO;
}

// this method is called when the user starts the image processing
// and the character recognition
- (IBAction)onProcess:(id)sender {
	//disable the processButton
	self.processButton.enabled = NO;
	// if the image was processed before, we use the results
	// from the previous processing
	if(processed) {
		[self ocrProcessingFinished:text];
		return;
	}
	// using a progress indicator when the image in processed so that
	// the user knows something is happening
	self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud.labelText = @"Applying filters";
    [self.view addSubview:self.progressHud];
    [self.progressHud showWhileExecuting:@selector(processOcrAt:) onTarget
										:self withObject
										:image animated:YES];
}

- (void)viewDidUnload
{
	
	[self setImageView:nil];
	[self setProcessButton:nil];
    [super viewDidUnload];
    if (![self.progressHud isHidden])
        [self.progressHud hide:NO];
    self.progressHud = nil;
}

/* restricts the orientation to portrait */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/* the method is used for processing the image with openCV 
 * and for sending it to tesseract*/
- (void)processOcrAt:(UIImage *)img
{

	//consider the rotation of the image when preparing it to for processing
	if(rotation > 0.01 || rotation < -0.01) {
		image = [image rotate:-rotation];
		imageView.transform = CGAffineTransformRotate([imageView transform], -rotation);
	}
	original = image;
	
	
	//START OPEN CV processing --------------------
	cv::Mat tempMat = [image CVGrayscaleMat];
	
	cv::Mat grayFrame, output;
	cv::Size size;
	size.height = 3;
	size.width = 3;
	
	cv::GaussianBlur(tempMat, tempMat, size, 0.8);
	cv::adaptiveThreshold(tempMat, output, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
	cv::GaussianBlur(output, output, size, 0.8);
		
	
	//putting the image in an UIImage format
	image = [UIImage imageWithCVMat:output];
	// END OPEN CV -----------------
	
	
	//update the image in the view
	[self performSelectorOnMainThread:@selector(refreshImage) withObject:nil waitUntilDone:YES];
	
	
	//save the image in photo album
	UIImageWriteToSavedPhotosAlbum (image, nil, nil , nil);
	 self.progressHud.labelText = @"Processing OCR";
	
	//get the appdelegate
	AppDelegate * del = [[UIApplication sharedApplication] delegate] ;
	TesseractWrapper * wrap = del.tessWrap;
	//send the image to tesseract
	NSString * recognized = [wrap recognizeImage:image];
	
	//after finishing the processing execute ocrProcessingFinished
    [self performSelectorOnMainThread:@selector(ocrProcessingFinished:)
                           withObject:recognized
                        waitUntilDone:NO]; 
}

- (void) refreshImage 
{
	imageView.image = image;
}

// this method is performed after running the character recognition
// algorithm
- (void)ocrProcessingFinished:(NSString *)result
{
	text = result;
	processed = YES;
	[self performSegueWithIdentifier:@"mine" sender:self];
	
}

// prepares to go to the next view - sends the recognized text, the
// processed image and the original image
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	((SecondViewController *)[segue destinationViewController]).theText = text;
	((SecondViewController *)[segue destinationViewController]).theImage = image;
	((SecondViewController *)[segue destinationViewController]).theOriginalImage = original;
	processButton.enabled = YES;

}


#pragma mark -
#pragma mark === Setting up and tearing down ===
#pragma mark

// adds a set of gesture recognizers to one of our piece subviews
- (void)addGestureRecognizersToPiece
{
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
	[rotationGesture setDelegate:self];
    [imageView addGestureRecognizer:rotationGesture];
	
	UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
	[tapGesture setDelegate:self];
	[imageView addGestureRecognizer:tapGesture];

    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [imageView addGestureRecognizer:pinchGesture];

    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [imageView addGestureRecognizer:panGesture];

   
}

#pragma mark -
#pragma mark === Utility methods  ===
#pragma mark

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
     
       piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
		piece.center = locationInSuperview;
    }
}


#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
	
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}
// when tapping on the the image view it toggles between the originial image
// and the processed image
- (void)tapPiece:(UITapGestureRecognizer *)gestureRecognizer
{
	if(imageView.image == original)
		imageView.image = image;
	else
    	imageView.image = original;
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
		rotation += [gestureRecognizer rotation];
        [gestureRecognizer setRotation:0];
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
		
    }
}

// ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously
// prevent other gesture recognizers from recognizing simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{    
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}

@end
