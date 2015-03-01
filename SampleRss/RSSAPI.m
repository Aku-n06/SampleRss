//
//  RSSAPI.m
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "RSSAPI.h"

@implementation RSSAPI

-(id)init {
    if(self == [super init]){
        //initialize
        isOnline = true;
    }
    return self;
}

-(void)getRssFromUrl:(NSURL *)sourceUrl{
    rssDownloader=[RSSDownloader sharedManager];
    [rssDownloader setDelegate:self];
    [rssDownloader getRssFromUrl:sourceUrl];
}

#pragma mark - RSSDownloaded delegate

-(void)rssDownloaderGotItem:(RSSItem *)loadedItem{
    if(isOnline == false){
        //comunicate the network status using notification
        isOnline = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkStatusChanged" object:self userInfo:@{@"isOnline":[NSNumber numberWithBool:isOnline]}];
    }
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
    if(isOnline == true){
        //comunicate the network status using notification
        isOnline = false;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkStatusChanged" object:self userInfo:@{@"isOnline":[NSNumber numberWithBool:isOnline]}];
    }
    //load rss data from memory (coredata)
    RSSDataManager *dataManager = [[RSSDataManager alloc] init];
    NSMutableArray *rssItems = [dataManager loadRssListFromDatabase];
    if(rssItems == nil){
        //no offline data - comunicate the completion
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompletedNotify" object:self];
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
