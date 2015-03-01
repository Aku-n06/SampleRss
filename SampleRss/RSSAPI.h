//
//  RSSAPI.h
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSSDownloader.h"
#import "RSSDataManager.h"
#import "RSSItem.h"

/* This is a façade class that manage the RSS feed:
use the RSSDownloader to download the feed from a web url and parse it
and the RSSDataManager to save the informations downloaded or retrieve that
in case of offline usage */
@interface RSSAPI : NSObject <RSSDownloaderDelegate> {
    RSSDownloader *rssDownloader;
    //network status
    BOOL isOnline;
}

-(void)getRssFromUrl:(NSURL *)sourceUrl;

@end
