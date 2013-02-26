//
//  ViewController.h
//  TesseractSample
//
//  Created by Ângelo Suzuki on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


@class MBProgressHUD;


@interface ViewController : UIViewController<UIGestureRecognizerDelegate>
{
    MBProgressHUD *progressHud;
	MBProgressHUD *progressFilter;
	__weak UIImageView *imageView;
	NSString * text;
	bool processed;
	CGFloat rotation;
	cv::Mat imageCV;
}

@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic, strong) MBProgressHUD *progressFilter;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage * image;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *processButton;
@property (nonatomic, strong) UIImage * original;

//- (void)setTesseractImage:(UIImage *)image;

@end
