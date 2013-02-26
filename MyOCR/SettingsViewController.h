//
//  SettingsViewController.h
//  TesseractSample
//
//  Created by Ruxandra Nistor on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
- (IBAction)clickOnSegmentedController:(id)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;

@end
