//
//  TableViewController.h
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSItem.h"
#import "DetailViewController.h"
#import "RSSAPI.h"

@interface TableViewController : UITableViewController {
    RSSAPI *rssApi;
    
    NSMutableArray *feeds;
    
    //Pull-to-refresh control to add to the table
    UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
