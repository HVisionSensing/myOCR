//
//  SettingsViewController.m
//  TesseractSample
//
//  Created by Ruxandra Nistor on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize segControl;


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
    [super viewDidLoad];
	self.title = @"Settings";
	// Do any additional setup after loading the view.
	self.segControl.autoresizesSubviews = YES;
}

- (void)viewDidUnload
{
    [self setSegControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// force orientation to portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// allows the user to choose the desired language for tesseract
- (IBAction)clickOnSegmentedController:(id)sender {
	int clickedSegment = [sender selectedSegmentIndex];	
	Language language;
	switch (clickedSegment) {
		case 0:
			language = kEng;
			break;
		case 1:
			language = kRon;
			break;
		case 2:
			language = kEng2;
			break;	
		default:
			break;
	}
	//get the Tesseract wrapper and change the language
	AppDelegate * del = [[UIApplication sharedApplication] delegate] ;
	TesseractWrapper * wrap = del.tessWrap;
	[wrap changeLanguage:language];

}
@end
