//
//  ArchiveViewController.h
//  MyOCR
//
//  Created by Ruxandra Nistor on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArchiveViewController : UITableViewController
@property (strong,nonatomic) NSArray *objects;
@property (atomic) NSInteger currentRow;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end
