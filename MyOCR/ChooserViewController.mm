//
//  ChooserViewController.m
//  MyOCRFixed
//
//  Created by Ruxandra Nistor on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChooserViewController.h"
#import "UIImage+processing.h"
#import "AppDelegate.h"

@interface ChooserViewController ()

@end

@implementation ChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:@"OCR"];
	//initialize tesseract
	AppDelegate * del = [[UIApplication sharedApplication] delegate] ;
	del.tessWrap =  [[TesseractWrapper alloc]initWithLanguage:kEng];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

// handle camera
- (IBAction)cameraPressed:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = 
        UIImagePickerControllerSourceTypeCamera;
		imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
		[imagePicker setCameraCaptureMode: UIImagePickerControllerCameraCaptureModePhoto];
        imagePicker.allowsEditing = NO;
	

        [self presentModalViewController:imagePicker 
                                animated:YES];
        newMedia = YES;
		
    }
}

//handle gallery
- (IBAction)GalleryPressed:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:
		 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
	{
		UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = 
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
		
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = NO;
    }
}


// handle input from imagePicker after finished picking a picture
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
       if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
		
		if(newMedia)
        	// Save the new image to the Camera Roll
	        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }

	//dismiss modal viewcontroler
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
	[self dismissModalViewControllerAnimated:YES];
	image = imageToSave;
	image  = [image fixOrientation];
	//make sure image size is not to big
	if(image.size.width> 1000 && image.size.height > 1500)	
		image = [image resize];
		
	picker = nil;
	imageToSave = nil;
	editedImage = nil;
	originalImage = nil;
	mediaType = nil;
	[self performSegueWithIdentifier:@"choose" sender:self];
	
}

//force interface to portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//send the image to the next viewcontroler
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

	[[segue destinationViewController] setImage:image];
	image = nil;
	
}


@end
