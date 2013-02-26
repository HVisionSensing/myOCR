//
//  ChooserViewController.h
//  TesseractSample
//
//  Created by Ruxandra Nistor on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//#include "ViewController.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>



@interface ChooserViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
	__strong UIImage * image;
	
	bool newMedia;
}

@end
