//
//  TableViewController.m
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

//sport
//#define rssUrl @"http://newsrss.bbc.co.uk/rss/sportonline_world_edition/front_page/rss.xml"
//top stories
//#define rssUrl @"http://feeds.bbci.co.uk/news/rss.xml"
//world
//#define rssUrl @"feed://feeds.bbci.co.uk/news/world/rss.xml"
//technology
#define rssUrl @"http://feeds.bbci.co.uk/news/technology/rss.xml"

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    isOnline=true;
    isFirstElementLoaded = false;
    
    //create the feed array empty
    feeds = [[NSMutableArray alloc] init];
    
    //add the notification used to add new elements to the table while loading
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addItem:)
                                                 name:@"downloadedItemNotify" object:nil];
    
    //add the notification called when all the element are loaded
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadingCompleted:)
                                                 name:@"downloadCompletedNotify" object:nil];
    
    //add the notification called when all the network status change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChanged:)
                                                 name:@"networkStatusChanged" object:nil];
    
    //add a spinner on the top of the tableview that will be used to refresh the data when the user will
    //pull the table down
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //start the spinner rotation animation
    [refreshControl beginRefreshing];
    
    //ask the model to retrieve the data of the rss
    NSURL *url = [NSURL URLWithString:rssUrl];
    rssApi = [[RSSAPI alloc] init];
    [rssApi getRssFromUrl:url];
    
    //add the change orientation notification
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

//in case of change of orientation reload the table to resize the cells
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}

//called when the user pull down the tableview, to refresh
-(void)startRefresh {
    
    //called when the tableview pulled down (pull to refresh)
    //prepare to clear all the displayed data from the tableView
    isFirstElementLoaded = false;
    //ask the api for new data
    NSURL *url = [NSURL URLWithString:rssUrl];
    [rssApi getRssFromUrl:url];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//called each time a new rss item is given from the rssApi
-(void)addItemToList:(RSSItem *)loadedItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isFirstElementLoaded == false) {
            if (isOnline == true) {
                //remove all the old picture stored in the temporary directory
                NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
                for (NSString *file in tmpDirectory) {
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
                }
            }
            isFirstElementLoaded = true;
            //clear the tableview
            [feeds removeAllObjects];
            [self.tableView reloadData];
        }
        //add element to the table
        NSInteger section = 0;
        NSInteger row;
        if (isOnline == false) {
            row = [feeds count] + 1;
        }else {
            row = [feeds count];
        }
        [feeds addObject:loadedItem];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        

        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    });
}

#pragma mark - UITableView data source

//set just one section in this table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//return the number of rows in the section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isOnline == false) {
        //add a new row (the first row that will show an offline feedback message to the user)
        return [feeds count] + 1;
    }
    return [feeds count];
}

//set the cell content (title, desctiption label, thumbnail)
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
    }
    else {
        //remove old title label
        UIView *oldTitleView = [cell.contentView viewWithTag:1];
        [oldTitleView removeFromSuperview];
        //remove old description label
        UIView *oldDescriptionView = [cell.contentView viewWithTag:2];
        [oldDescriptionView removeFromSuperview];
        //remove the old thumbnail view (UIWebImageView) if existing, using the tag
        UIView *oldThumbnailView = [cell.contentView viewWithTag:3];
        [oldThumbnailView removeFromSuperview];
    }

    if (isOnline == false && indexPath.row == 0) {
        //in case of offline usage the first row will show an offline feedback message to the user
        UILabel *descriptionLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 20)];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.font = [UIFont fontWithName:@"GeosansLight" size:14.0];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.backgroundColor = [UIColor colorWithRed:1 green:0.27 blue:0.24 alpha:1];
        descriptionLabel.text = @"offline";
        descriptionLabel.tag = 2;
        [cell.contentView addSubview:descriptionLabel];
    }
    else {
        //adjust the index of the element is going to be loaded in case of offline usage becouse in that particular case in the
        //first row will be displayed an "offline" message to the user
        
        RSSItem *currentItem = [[RSSItem alloc] init];
        if (isOnline == false) {
            currentItem = [feeds objectAtIndex:indexPath.row - 1];
        }
        else {
            currentItem = [feeds objectAtIndex:indexPath.row];
        }
        
        //set the title of the cell, multirow, size to fit
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(120, 20, self.view.frame.size.width-130, 20)];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont fontWithName:@"GeosansLight" size:18.0];
        titleLabel.text = currentItem.titleText;
        [titleLabel sizeToFit];
        titleLabel.tag = 1;
        [cell.contentView addSubview:titleLabel];
        
        //set the description of the cell, multirow, size to fit
        UILabel *descriptionLabel =[[UILabel alloc] initWithFrame:CGRectMake(120, titleLabel.frame.size.height + 10, self.view.frame.size.width-130, 20)];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.font = [UIFont fontWithName:@"GeosansLight" size:14.0];
        descriptionLabel.text = currentItem.descriptionText;
        [descriptionLabel sizeToFit];
        descriptionLabel.tag = 2;
        [cell.contentView addSubview:descriptionLabel];
        
        //thumbnail
        if (currentItem.mediaPictureUrl != nil) {
            //add a UIWebImageView, that will download the picture asynch
            UIWebImageView *thumbnailView = [[UIWebImageView alloc] initWithFrame:CGRectMake(10, 20, 100, 100)];
            [thumbnailView getPictureFromUrl:currentItem.mediaPictureUrl];
            thumbnailView.tag = 3; //so that it can be removed when this cell will be reused
            [cell.contentView addSubview:thumbnailView];
        }
    }
    
    return cell;
}

//set the dynamic height of the cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isOnline == false && indexPath.row == 0) {
        //in case of offline usage the first row will show an offline feedback message to the user
        return 20;
    }
    
    //adjust the index of the element is going to be loaded in case of offline usage, becouse in that particular case in the
    //first row will be displayed an "offline" message for the user
    RSSItem *currentItem = [[RSSItem alloc] init];
    if (isOnline == false) {
        currentItem = [feeds objectAtIndex:indexPath.row - 1];
    }else {
        currentItem = [feeds objectAtIndex:indexPath.row];
    }
    //call a function to calculate the cell height from the title and the description that will be displayed on it
    float cellSize = [self heightForTitle:currentItem.titleText withDetail:currentItem.descriptionText];
    
    return cellSize ;
}

//this method calculate the cell dimension considering the content will populate it
-(CGFloat)heightForTitle:(NSString *)title withDetail:(NSString *)detail {
    
    //max height for a cell (if zero, no limitation)
    NSInteger maxHeight = 0;
    

    //set the title of the cell, multirow, size to fit
    UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(120, 20, self.view.frame.size.width-130, 20)];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont fontWithName:@"GeosansLight" size:18.0];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    
    //set the description of the cell, multirow, size to fit
    UILabel *descriptionLabel =[[UILabel alloc] initWithFrame:CGRectMake(120, titleLabel.frame.size.height, self.view.frame.size.width-130, 20)];
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont fontWithName:@"GeosansLight" size:14.0];
    descriptionLabel.text = detail;
    [descriptionLabel sizeToFit];
    
    //make the calculation (10 is the space between the title and the description)
    float calculatedSize =titleLabel.frame.size.height + 10 + descriptionLabel.frame.size.height;
    if (calculatedSize > maxHeight && maxHeight != 0) {
        calculatedSize = maxHeight;
    }
    return calculatedSize;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isOnline == false) {
        
        //when offline the DetailView is disable, so remove the gray selection and add
        //a red animation to give the user a feedback that this view can't be opened
        //offline
        
        //remove selection effect
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        //add red pulsing animation
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        selectedCell.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        UIViewAnimationOptions option1 = UIViewAnimationOptionOverrideInheritedDuration;
        [UIView transitionWithView:selectedCell
                          duration:1
                           options:option1
                        animations:^{
                            selectedCell.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0];
                        }
                        completion:nil];
        
    }else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //disabled the detailView for offline usage
    if ([identifier isEqualToString:@"showDetails"]) {
        if (isOnline == false) {
            return NO;
        }
    }
    return YES;
}

//this is used to pass the selected item data to the DetailViewController when the user select a cell
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        RSSItem *selectedItem=[[RSSItem alloc] init];
        selectedItem=[feeds objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setUrlString:selectedItem.sourceUrl];
    }
    
}

#pragma mark - RSSAPI notification response

-(void)addItem:(NSNotification *)notif {
    [self addItemToList:[[notif userInfo] valueForKey:@"rssItemResultsKey"]];
}

-(void)networkStatusChanged:(NSNotification *)notif {
    //update the flag and the interface, adding on removing the first row "offline" message
    BOOL newOnlineFlag = [[[notif userInfo] valueForKey:@"isOnline"] boolValue];
    
    if (newOnlineFlag != isOnline) {
        
        //network status changed
        isOnline = newOnlineFlag;
        
        if (isOnline == true) {
            //remove the first row with the "offline message"
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        }else {
            //add the first row with the "offline message"
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        }
    }
}

-(void)loadingCompleted:(NSNotification *)notif {
    
    //stop the spinner animation so that it can be used by the user to refresh the table
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

@end
