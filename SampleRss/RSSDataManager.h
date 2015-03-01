//
//  RSSDataManager.h
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RSSItem.h"

//this class save and load the RSS informations using coredata framework
@interface RSSDataManager : NSObject

//used to add an Article with xcdatamodel to the database
-(BOOL)addItemsToDatabase:(NSMutableArray *)rssItems;
//load all the Articles stored in the database and retourn them
-(NSMutableArray *)loadRssListFromDatabase;
//remove all the data from the database
-(BOOL)cleanData;

@end
