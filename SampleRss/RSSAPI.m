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
    if (self == [super init]) {
        //initialize
        isOnline = true;
    }
    return self;
}

-(void)getRssFromUrl:(NSURL *)sourceUrl {
    rssDownloader=[RSSDownloader sharedManager];
    [rssDownloader setDelegate:self];
    [rssDownloader getRssFromUrl:sourceUrl];
}

#pragma mark - RSSDownloaded delegate

-(void)rssDownloaderGotItem:(RSSItem *)loadedItem {
    if (isOnline == false) {
        //comunicate the network status using notification
        isOnline = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkStatusChanged" object:self userInfo:@{@"isOnline":[NSNumber numberWithBool:isOnline]}];
    }
    //comunicate data using notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadedItemNotify" object:self userInfo:@{@"rssItemResultsKey":loadedItem}];
}

-(void)rssDownloaderCompleteRssArray:(NSMutableArray *)rssItems withError:(NSError *)error {
    if (error) {
        //error parsing data
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"Cannot manage this feed source!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else {
        RSSDataManager *dataManager = [[RSSDataManager alloc] init];
        //comunicate the completion
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompletedNotify" object:self];
        //clear old data if existing
        [dataManager cleanData];
        //save data to memory
        if ([dataManager addItemsToDatabase:rssItems] == NO) {
            //error saving data
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"An error occurred when saving data offline"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

-(void)rssDownloaderNetworkError:(NSError *)error {
    if (isOnline == true) {
        //comunicate the network status using notification
        isOnline = false;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkStatusChanged" object:self userInfo:@{@"isOnline":[NSNumber numberWithBool:isOnline]}];
    }
    //load rss data from memory (coredata)
    RSSDataManager *dataManager = [[RSSDataManager alloc] init];
    NSMutableArray *rssItems = [dataManager loadRssListFromDatabase];
    if ([rssItems count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"There isn't offline data available, connect to download new data"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        //no offline data - comunicate the completion
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompletedNotify" object:self];
    }else {
        for(int i=0; i < [rssItems count]; i++) {
            //comunicate data using notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadedItemNotify" object:self userInfo:@{@"rssItemResultsKey":[rssItems objectAtIndex:i]}];
        }
        //comunicate the completion
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompletedNotify" object:self];
    }
}

@end
