//
//  TableViewController.h
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSRssItem.h"
#import "DetailViewController.h"
#import "RSSDownloader.h"

@interface TableViewController : UITableViewController <RSSDownloaderDelegate>{
    RSSDownloader *rssDownloader;
    
    NSMutableArray *feeds;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
