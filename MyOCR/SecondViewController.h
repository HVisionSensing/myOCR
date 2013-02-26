//
//  SecondViewController.h
//  TesseractSample
//
//  Created by Ruxandra Nistor on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UIImagePickerControllerDelegate, UITextViewDelegate> {
	
}
- (IBAction)saveToArchive:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString * theText;
@property (strong, nonatomic) UIImage * theImage;
@property (strong, nonatomic) UIImage * theOriginalImage;
@property (strong, nonatomic) UITextField *myTextField;
@end
