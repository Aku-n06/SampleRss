//
//  TableViewController.m
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//
#define rssUrl @"http://newsrss.bbc.co.uk/rss/sportonline_world_edition/front_page/rss.xml"
#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

-(void)viewDidLoad {
    [super viewDidLoad];

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
    
    //add loading spinner animation
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[UIColor blackColor]];
    [refreshControl setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1]];
    [self.tableView addSubview:refreshControl];
    //start nimation
    [refreshControl beginRefreshing];
    
    //start to get the rssItems
    NSURL *url = [NSURL URLWithString:rssUrl];
    rssApi = [[RSSAPI alloc] init];
    [rssApi getRssFromUrl:url];
    
}

-(void)startRefresh{
    //called when the tableview pulled down (pull to refresh)
    //clear the data
    [feeds removeAllObjects];
    [self.tableView reloadData];
    //ask the api for new data
    NSURL *url = [NSURL URLWithString:rssUrl];
    [rssApi getRssFromUrl:url];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addItemToList:(RSSItem *)loadedItem{
    dispatch_async(dispatch_get_main_queue(), ^{
        //add element to the table
        NSInteger section = 0;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[feeds count] inSection:section];
        [feeds addObject:loadedItem];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    });
}

#pragma mark - UITableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return feeds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    RSSItem *currentItem = [feeds objectAtIndex:indexPath.row];
    
    //title
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = currentItem.titleText;
    [cell.textLabel sizeToFit];
    
    //description
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = currentItem.descriptionText;
    [cell.textLabel sizeToFit];
    
    //thumbnail
    cell.imageView.image = [UIImage imageNamed:@"defaultThumbnail.png"];
    
    if(currentItem.mediaPictureUrl!=nil){
        //download the picture
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = [NSURL URLWithString:currentItem.mediaPictureUrl];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:
        ^(NSURL *location, NSURLResponse *response, NSError *error){
            if(error == nil){
                //retrive the data from disk
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:location];
                //save the picture on temp directory
                #warning realize the offline cache
                UIImage *image = [UIImage imageWithData:imageData];
                image=[self imageWithImage:image scaledToWidth:100];
                //show the image
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image=image;
                });
            }
        }];
        [task resume];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSItem *currentItem = [feeds objectAtIndex:indexPath.row];
    float cellSize = [self heightForTitle:currentItem.titleText withDetail:currentItem.descriptionText];
    
    return cellSize ;
}

//this method resize the picture height (used to keep the width to 100 px)
-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) width{
    
    float oldWidth = sourceImage.size.width;
    float scaleFactor = width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//this method calculate the cell dimension considering the content will populate it
-(CGFloat)heightForTitle:(NSString *)title withDetail:(NSString *)detail{
    
    NSInteger MAX_HEIGHT = 2000;
    
    UILabel * titleTextView= [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width-100, 20)];
    titleTextView.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.numberOfLines = 0;
    titleTextView.font = [UIFont fontWithName:@"System" size:16.0];
    titleTextView.text = title;
    [titleTextView sizeToFit];
    
    UILabel * detailTextView= [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width-100, 20)];
    detailTextView.lineBreakMode = NSLineBreakByWordWrapping;
    detailTextView.numberOfLines = 0;
    detailTextView.font = [UIFont fontWithName:@"System" size:11.0];
    detailTextView.text = detail;
    [detailTextView sizeToFit];
    
    float calculatedSize =titleTextView.frame.size.height + detailTextView.frame.size.height;
    if(calculatedSize > MAX_HEIGHT){
        calculatedSize = MAX_HEIGHT;
    }
    return calculatedSize;
}

#pragma mark - storyboard

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"showDetails"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        RSSItem *selectedItem=[[RSSItem alloc] init];
        selectedItem=[feeds objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] showRssItem:selectedItem];
    }
}


#pragma mark - RSSAPI notification response

-(void)addItem:(NSNotification *)notif{
    [self addItemToList:[[notif userInfo] valueForKey:@"rssItemResultsKey"]];
}

-(void)loadingCompleted:(NSNotification *)notif{
    //start nimation
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

@end
