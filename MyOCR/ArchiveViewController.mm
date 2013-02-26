//
//  ArchiveViewController.m
//  MyOCR
//
//  Created by Ruxandra Nistor on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchiveViewController.h"
#import "AppDelegate.h"
#import "DetailsViewController.h"
#import "UIImage+processing.h"

@interface ArchiveViewController ()

@end

@implementation ArchiveViewController

@synthesize tableView = _tableView;
@synthesize objects = _objects;
@synthesize currentRow = _currentRow;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		    }
    return self;
}


- (void) loadCoreData {
	//load core data and request the needed objects
	AppDelegate *appDelegate =[[UIApplication sharedApplication] delegate]; 
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Receipt"inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:entityDescription];
	NSError *error;
	self.objects = [context executeFetchRequest:request error:&error]; 
	if (self.objects == nil) {
		// Do whatever error handling is appropriate 
		NSLog(@"There was an error!");
		
	}
	
}
- (void)viewDidLoad
{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
	delegate.archiveViewController = self;

	[self loadCoreData];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated {
//TODO: conditie aici
	[self loadCoreData];
	[self.tableView reloadData];
}

- (void)viewDidUnload
{
	[self setTableView:nil];
	[self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// force the imterface to portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//return number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// return number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    static NSString *CellIdentifier = @"ReceiptCell";
	
	//reuse cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
	// cutomize the cell - put the text and thumbnail image
    NSManagedObject *oneObject = [self.objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [oneObject valueForKey:@"name"];
	cell.detailTextLabel.text = @"24.05.2011";
	[cell.imageView sizeToFit];
	UIImage * thumbnail = [UIImage imageWithData:[oneObject valueForKey:@"thumbnail"]];
	cell.imageView.image = thumbnail;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

// this method allows going in the details view when selecting an entry
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
	self.currentRow = indexPath.row;
	[self performSegueWithIdentifier:@"details" sender:self];

}

// this methos tells the detailsviewcontroller which object it to detail
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	
	[(DetailsViewController *)[segue destinationViewController] setObject:[self.objects objectAtIndex:self.currentRow]];
}


// allow editing of table (set YES because we need to be able to delete)
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// this mathod allows the user to delete an entry from the core data
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
		//get the context
		AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
		NSManagedObjectContext *context = [delegate managedObjectContext];
		
		//delete the object
		[context deleteObject:[self.objects objectAtIndex:indexPath.row]];
		//save the context
		NSError *error;
		[context save:&error];
		
		//refresh the information
		[self loadCoreData];
		[self.tableView reloadData];
		
	}
}


@end
