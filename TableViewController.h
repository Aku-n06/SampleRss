//
//  TableViewController.h
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController <NSXMLParserDelegate>{
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *rssItem;
    NSMutableString *rssTitle;
    NSMutableString *rssLink;
    NSString *element;
    
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
