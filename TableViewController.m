//
//  TableViewController.m
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//
//#define rssUrl @"http://rss.cnn.com/rss/cnn_tech.rss"
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
    
    //add a spinner on the top of the tableview that will be used to refresh the data when the user will
    //pull the table down
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[UIColor blackColor]];
    [refreshControl setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1]];
    [self.tableView addSubview:refreshControl];
    
    //start the spinner rotation animation
    [refreshControl beginRefreshing];
    
    //ask the model to retrieve the data of the rss
    NSURL *url = [NSURL URLWithString:rssUrl];
    rssApi = [[RSSAPI alloc] init];
    [rssApi getRssFromUrl:url];
    
}

//called when the user pull down the tableview, to refresh
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

//called each time a new rss item is given from the rssApi
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

//set just one section in this table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//return the number of rows in the section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

//set the cell content (title, desctiption label, thumbnail)
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if(cell!=nil){
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
    
    RSSItem *currentItem = [feeds objectAtIndex:indexPath.row];
    
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
    //set an imageview so to align title and description for the uiwebimageview
    cell.imageView.image = [UIImage imageNamed:@"defaultThumbnail"];
    if(currentItem.mediaPictureUrl!=nil){
        //add a UIWebImageView, that will download the picture asynch
        UIWebImageView *thumbnailView = [[UIWebImageView alloc] initWithFrame:CGRectMake(10, 20, 100, 100)];
        [thumbnailView getPictureFromUrl:currentItem.mediaPictureUrl];
        thumbnailView.tag = 3; //so that it can be removed when this cell will be reused
        [cell.contentView addSubview:thumbnailView];
    }
    
    return cell;
}

//set the dynamic height of the cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSItem *currentItem = [feeds objectAtIndex:indexPath.row];
    //call a function to calculate the cell height from the title and the description that will be displayed on it
    float cellSize = [self heightForTitle:currentItem.titleText withDetail:currentItem.descriptionText];
    
    return cellSize ;
}

//this method calculate the cell dimension considering the content will populate it
-(CGFloat)heightForTitle:(NSString *)title withDetail:(NSString *)detail{
    
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
    if(calculatedSize > maxHeight && maxHeight != 0){
        calculatedSize = maxHeight;
    }
    return calculatedSize;
}

#pragma mark - Navigation

//this is used to pass the selected item data to the DetailViewController when the user select a cell
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"showDetails"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        RSSItem *selectedItem=[[RSSItem alloc] init];
        selectedItem=[feeds objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setUrlString:selectedItem.sourceUrl];
    }
}


#pragma mark - RSSAPI notification response

-(void)addItem:(NSNotification *)notif{
    [self addItemToList:[[notif userInfo] valueForKey:@"rssItemResultsKey"]];
}

-(void)loadingCompleted:(NSNotification *)notif{
    //stop the spinner animation so that it can be used by the user to refresh the table
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

@end
