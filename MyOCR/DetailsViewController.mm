//
//  DetailsViewController.m
//  MyOCR
//
//  Created by Ruxandra Nistor on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController
@synthesize roundedview;
@synthesize object;
@synthesize imageView;
@synthesize textView;
@synthesize before, after;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	//set the title
	self.title = [object valueForKey:@"name"];
	
	int theID = [[object valueForKey:@"id"] integerValue];
	AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
	
	NSString * path = [delegate getDocumentsDirectory];
	NSString * beforePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.before",theID]];
	NSString * afterPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.after",theID]];
	
	//get before image
	NSData * dataBytes = [NSData dataWithContentsOfFile:beforePath];
	before = [UIImage imageWithData:dataBytes];
    
	//get after image
	dataBytes = [NSData dataWithContentsOfFile:afterPath];
	after = [UIImage imageWithData:dataBytes];
	
	//set imageView to before image
	imageView.image = before;
	
	//set the recognizet text
	self.textView.text = [object valueForKey:@"text"];
	self.textView.editable = NO;
	
	//add nice visuals
	self.roundedview.layer.shadowRadius = 7;
	self.roundedview.layer.shadowOpacity = 0.9;
	self.roundedview.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.roundedview.clipsToBounds = NO;
	self.roundedview.hidden = YES;
	
	self.imageView.layer.shadowRadius = 7;
	self.imageView.layer.shadowOpacity = 0.9;
	self.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.imageView.clipsToBounds = NO;

	CGSize size;
	size.height = 5;
	size.width = 5;
	self.textView.layer.shadowOffset = size;
	
	//add the tap gesture to toggle betwen before and after images
	UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
	[tapGesture setDelegate:self];
	[imageView addGestureRecognizer:tapGesture];
    
	//call parent method
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[self setImageView:nil];
	[self setTextView:nil];
	[self setRoundedview:nil];
	self.before = nil;
	self.after = nil;
	self.object = nil;
    [super viewDidUnload];
}
-(void) viewWillDisappear:(BOOL)animated {
	self.before = nil;
	self.after = nil;
	self.object = nil;
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)didChangeSelection:(id)sender {
		textView.hidden = !textView.hidden;
		imageView.hidden = !imageView.hidden;
		roundedview.hidden = !roundedview.hidden;
}


// toggle between original image and processed image
- (void)tapPiece:(UIGestureRecognizer *)gestureRecognizer
{

	if(imageView.image == before)
		imageView.image = after;
	else
    	imageView.image = before;
}

// doesn't allow simultaneous gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return NO;
}

@end
