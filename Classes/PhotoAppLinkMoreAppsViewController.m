//
//  PhotoAppLinkMoreAppsViewController.m
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 11-05-22.
//  Copyright 2011 Pocket Pixels Inc. All rights reserved.
//

#import "PhotoAppLinkMoreAppsViewController.h"
#import "PhotoAppLinkManager.h"  

@implementation PhotoAppLinkMoreAppsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        PhotoAppLinkManager* palManager = [PhotoAppLinkManager sharedPhotoAppLinkManager];
        NSPredicate* notInstalledPred = [NSPredicate predicateWithFormat:@"%K=FALSE", @"installed"];
        additionalApps =  [palManager.supportedApps filteredArrayUsingPredicate:notInstalledPred];
        [additionalApps retain];
    }
    return self;
}

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)dealloc
{
    [additionalApps release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = 80;
    self.navigationItem.title = NSLocalizedString(@"Compatible Apps", @"PhotoAppLink");

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [additionalApps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PALAppInfoCell";
    const int APPNAME_LABEL_TAG = 1;
    const int SEND_RECEIVE_LABEL_TAG = 2;
    const int DESCRIPTION_LABEL_TAG = 3;
    const int STORE_BUTTON_TAG = 4;
    const int leftTextBoundary = 75;
    const int titleTopMargin = 10;
    const int titleHeight = 20;
    const int titleRightMargin = 10;
    
    UILabel* titleLabel;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        // configure app title label
        CGRect titleRect = CGRectMake(leftTextBoundary, titleTopMargin, 320-leftTextBoundary - titleRightMargin, titleHeight);
        titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        titleLabel.tag = APPNAME_LABEL_TAG;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:1.0];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [cell.contentView addSubview:titleLabel];
        
        // add button to go to App Store
        UIButton* storeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [storeButton addTarget:self action:@selector(storeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [storeButton setTitle:@"Store" forState:UIControlStateNormal];
        storeButton.frame = CGRectMake(265, 30, 50, 32);
        [cell.contentView addSubview:storeButton];
    }
    else {
        titleLabel = (UILabel*) [cell.contentView viewWithTag:APPNAME_LABEL_TAG];
    }
    
    PALAppInfo* appInfo = [additionalApps objectAtIndex:indexPath.row];
//    [titleLabel setText:@"123456789012345678901234567890"];
    [titleLabel setText:appInfo.appName];
    [[cell imageView] setImage:appInfo.thumbnail];
    [[cell detailTextLabel] setText:appInfo.appDescription];
    UIButton* storeButton = (UIButton*) cell.accessoryView;
    storeButton.tag = indexPath.row;
    return cell;
}

- (void)storeButtonTapped:(id)sender
{
    UIButton* tappedButton = sender;
    PALAppInfo* appInfo = [additionalApps objectAtIndex:tappedButton.tag];
    // TODO dismiss modal view controller?
    NSURL* appStoreURL = [appInfo appStoreLink];
    if (appStoreURL != nil) {
        [[UIApplication sharedApplication] openURL:appStoreURL];        
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
