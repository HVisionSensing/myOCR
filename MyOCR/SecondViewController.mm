//
//  SecondViewController.m
//  TesseractSample
//
//  Created by Ruxandra Nistor on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"
#import "UIImage+processing.h"
@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize theText;
@synthesize textView;
@synthesize theImage;
@synthesize myTextField;
@synthesize theOriginalImage;

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
	// Do any additional setup after loading the view.
	[[self textView] setText:theText];
	self.textView.delegate = self;
	
}

- (void)viewDidUnload
{
	[self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}

// force portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// this method is called when a user wants to save the current image
// processing
- (IBAction)saveToArchive:(id)sender {


	UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"New receipt"
														  message:@"Type the name of the receipt" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	self.myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
	[self.myTextField setBackgroundColor:[UIColor whiteColor]];
	[myAlertView addSubview:self.myTextField];
	[myAlertView show];
}

// registers the action on click and
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1) {
		AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
		
		NSString * path = [delegate getDocumentsDirectory];
	
	
		NSString *idPath = [path stringByAppendingPathComponent:@"id"];
		NSInteger theID;
		//in the id file we will remember the last used id
		if ([[NSFileManager defaultManager] fileExistsAtPath:idPath]) 	
		{
			NSString * str = [NSString stringWithContentsOfFile:idPath encoding:NSUTF8StringEncoding error:NULL];
			theID = [str integerValue];	
			theID ++;
			str = nil;
			str = [NSString stringWithFormat:@"%d", theID];
			[str writeToFile:idPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
				
		} else {
			//if the file was not created, we create it and initialize it with id 0
			theID = 0;
			NSString * str = [NSString stringWithFormat:@"%d", theID];
			[str writeToFile:idPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
		}
		//compose the name of the file
		NSString * beforePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.before",theID]];
		NSString * afterPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.after",theID]];
		
		//transform the original image to a byte buffer and write it to a file
		NSData * imageData = UIImagePNGRepresentation(theOriginalImage);
		[imageData writeToFile:beforePath atomically:YES];
		
		//transform the processed image to a byte buffer and write it to a file
		imageData = UIImagePNGRepresentation(theImage);
		[imageData writeToFile:afterPath atomically:YES];
		
		
		//"compose" the entry for coredata
		NSManagedObjectContext *context = [delegate managedObjectContext];
		NSManagedObject * theLine = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt"
															  inManagedObjectContext:context];
		[theLine setValue:self.myTextField.text forKey:@"name"];
		[theLine setValue:theText forKey:@"text"];
		
		NSDate *date = [NSDate date];	
		[theLine setValue:date forKey:@"date"];
		[theLine setValue:[NSNumber numberWithInt:theID] forKey:@"id"];
		
		UIImage * thumbnail = [theOriginalImage makeThumbnail];
		NSData * thumbData = UIImagePNGRepresentation(thumbnail);
		[theLine setValue:thumbData forKey:@"thumbnail"];
		
		NSError *error;
		//save the managed object to core data
		[context save:&error];
		if(delegate.archiveViewController == nil)
			NSLog(@"ARCHIVE = nil");
		if(delegate.archiveViewController.tableView == nil)
			NSLog(@"TABLEVIEW = nil");
		[delegate.archiveViewController.tableView reloadData];
	}
}



@end
