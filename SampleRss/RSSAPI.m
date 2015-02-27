//
//  RSSAPI.m
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "RSSAPI.h"

@implementation RSSAPI

-(void)getRssFromUrl:(NSURL *)sourceUrl{
    rssDownloader=[RSSDownloader sharedManager];
    [rssDownloader setDelegate:self];
    [rssDownloader getRssFromUrl:sourceUrl];
}

#pragma mark - RSSDownloaded delegate

-(void)rssDownloaderGotItem:(RSSItem *)loadedItem{
    //comunicate data using notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadedItemNotify" object:self userInfo:@{@"rssItemResultsKey":loadedItem}];
}

-(void)rssDownloaderCompleteRssArray:(NSMutableArray *)rssItems withError:(NSError *)error{
    if(error){
        #warning error parsing data
    }else{
        RSSDataManager *dataManager = [[RSSDataManager alloc] init];
        //comunicate the completion
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompletedNotify" object:self];
        //clear old data if existing
        [dataManager cleanData];
        //save data to memory
        if([dataManager addItemsToDatabase:rssItems] == NO){
            #warning error saving data
        }
        
    }
}

-(void)rssDownloaderNetworkError:(NSError *)error{
    //load rss data from memory (coredata)
    RSSDataManager *dataManager = [[RSSDataManager alloc] init];
    NSMutableArray *rssItems = [dataManager loadRssListFromDatabase];
    if(rssItems == nil){
        #warning no offline data available
    }else{
        for(int i=0; i < [rssItems count]; i++){
            //comunicate data using notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadedItemNotify" object:self userInfo:@{@"rssItemResultsKey":[rssItems objectAtIndex:i]}];
        }
        //comunicate the completion
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompletedNotify" object:self];
    }
}

@end
