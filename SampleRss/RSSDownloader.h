//
//  RSSDownloader.h
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSRssItem.h"

@protocol RSSDownloaderDelegate <NSObject>
    @optional
    -(void)rssDownloaderGotItem:(NSRssItem *)loadedItem;
@end

@interface RSSDownloader : NSObject <NSXMLParserDelegate>{
    //parser of the rss downloaded
    NSXMLParser *parser;
    //current string of the downloading attribute
    NSMutableString *currentAttribute;
    //current rss item downloading
    NSRssItem *currentItem;
    
    BOOL isDownloading;
}

@property(nonatomic, assign) id<RSSDownloaderDelegate> delegate;

-(void)getRssFromUrl:(NSURL *)sourceUrl;
//singleton method
+ (id)sharedManager;

@end
