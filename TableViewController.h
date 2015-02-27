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
#import "UIWebImageView.h"

/* this class manage the apparence and the content of the tableview
the table informations are stored in the feeds array, the class use arrApi
so provide the data called at startup and when the frefreshControl is used.
Each cell show a title, a description of the article and a thumbnail; this last
element is downloaded from a uiview subclass called UIVebImageView.
Selecting a cell the DetailViewController will be called. */
@interface TableViewController : UITableViewController {
    //Model that give the data for the table
    RSSAPI *rssApi;
    //Array containing all the feed informations
    NSMutableArray *feeds;
    //Pull-to-refresh control to add to the table
    UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
