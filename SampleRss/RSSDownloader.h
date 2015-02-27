//
//  RSSDownloader.h
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSSItem.h"

@protocol RSSDownloaderDelegate <NSObject>
@optional
-(void)rssDownloaderGotItem:(RSSItem *)loadedItem;
-(void)rssDownloaderCompleteRssArray:(NSMutableArray *)rssItems withError:(NSError *)error;
-(void)rssDownloaderNetworkError:(NSError *)error;
@end

/* This singleton class download a given rss url, parse it, store the data of each
item on RSSItem classes and send it in a notification.*/
@interface RSSDownloader : NSObject <NSXMLParserDelegate>{
    //parser of the rss downloaded
    NSXMLParser *parser;
    //current string of the downloading attribute
    NSMutableString *currentAttribute;
    //current rss item downloading
    RSSItem *currentItem;
    //contains all the item parsed
    NSMutableArray *rssItems;
    //ceck if the parser is working or have finished
    BOOL isParsing;
}

@property(nonatomic, assign) id<RSSDownloaderDelegate> delegate;

-(void)getRssFromUrl:(NSURL *)sourceUrl;
//singleton method
+ (id)sharedManager;

@end