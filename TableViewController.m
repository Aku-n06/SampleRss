//
//  TableViewController.m
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //create the feed array empty
    feeds = [[NSMutableArray alloc] init];
    
    //add the notification used to add new elements to the table while loading
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addItem:)
                                                 name:@"downloadedItemNotify" object:nil];
    
    //start to get the rssItems
    NSURL *url = [NSURL URLWithString:@"http://newsrss.bbc.co.uk/rss/sportonline_world_edition/front_page/rss.xml"];
    rssDownloader=[[RSSDownloader alloc] init];
    [rssDownloader setDelegate:self];
    [rssDownloader getRssFromUrl:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addItemToList:(NSRssItem *)loadedItem{
    [self.tableView beginUpdates];
    //add element to the table
    NSInteger section = 0;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[feeds count] inSection:section];
    [feeds addObject:loadedItem];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSRssItem *currentItem = [feeds objectAtIndex:indexPath.row];
    cell.textLabel.text = currentItem.titleText;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"showDetails"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSRssItem *selectedItem=[[NSRssItem alloc] init];
        selectedItem=[feeds objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] showRssItem:selectedItem];
    }
}

#pragma mark - RSSDownloaded delegate

-(void)rssDownloaderGotItem:(NSRssItem *)loadedItem{
    [self addItemToList:loadedItem];
}

#pragma mark - RSSDownloaded notification

- (void)addItem:(NSNotification *)notif {
    
    assert([NSThread isMainThread]);
    [self addItemToList:[[notif userInfo] valueForKey:@"rssItemResultsKey"]];
}

@end
