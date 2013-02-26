//
//  DetailsViewController.h
//  MyOCR
//
//  Created by Ruxandra Nistor on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController <UIGestureRecognizerDelegate>
- (IBAction)didChangeSelection:(id)sender;
@property (strong, nonatomic) NSManagedObject * object;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIImage *before;
@property (weak, nonatomic) IBOutlet UIView *roundedview;
@property (strong, nonatomic) UIImage *after;

@end
