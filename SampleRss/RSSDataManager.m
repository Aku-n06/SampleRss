//
//  RSSDataManager.m
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "RSSDataManager.h"

@implementation RSSDataManager

-(BOOL)addItemsToDatabase:(NSMutableArray *)rssItems{
    BOOL success=YES;
    //create entity and add store on it the Item data
    
    for(int i=0; i<[rssItems count]; i++){
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RSSItem" inManagedObjectContext:[self managedObjectContext]];
        NSManagedObject *newItem = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[self managedObjectContext]];
        RSSItem *rssItem = [rssItems objectAtIndex:i];
        
        [newItem setValue:rssItem.titleText forKey:@"titleText"];
        [newItem setValue:rssItem.upDate forKey:@"upDate"];
        [newItem setValue:rssItem.descriptionText forKey:@"descriptionText"];
        [newItem setValue:rssItem.sourceUrl forKey:@"sourceUrl"];
        [newItem setValue:rssItem.mediaPictureUrl forKey:@"mediaPictureUrl"];
        
        //add the entity to coredata and save
        NSError *error = nil;
        if (![newItem.managedObjectContext save:&error]) {
            success = NO;
            NSLog(@"Unable to save");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
    return success;
}

-(NSMutableArray *)loadRssListFromDatabase{
    NSMutableArray *tempItemList=[[NSMutableArray alloc]init];
    
    //create the request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RSSItem" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entityDescription];
    
    //send request
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        //in case of error will return a empty array
        NSLog(@"Unable to load");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        //estract the Item informations and store them in the array to retourn
        for(int i=0; i<result.count; i++){
            
            NSManagedObject *loadedItem = (NSManagedObject *)[result objectAtIndex:i];
            RSSItem *rssItem = [[RSSItem alloc] init];
            
            rssItem.titleText = [loadedItem valueForKey:@"titleText"];
            rssItem.upDate = [loadedItem valueForKey:@"upDate"];
            rssItem.descriptionText = [loadedItem valueForKey:@"descriptionText"];
            rssItem.sourceUrl = [loadedItem valueForKey:@"sourceUrl"];
            rssItem.mediaPictureUrl = [loadedItem valueForKey:@"mediaPictureUrl"];
            
            [tempItemList addObject:rssItem];
        }
    }
    
    return tempItemList;
}


-(BOOL)cleanData{
    BOOL success=YES;
    
    //remove all the pictures
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
    
    //create the request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RSSItem" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entityDescription];
    
    //send request
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    //ceck if the data exists
    if(result.count>0){
        //clear all and update all
        for (NSManagedObject * tempFeed in result) {
            [[self managedObjectContext] deleteObject:tempFeed];
        }
        NSError *saveError = nil;
        [[self managedObjectContext] save:&saveError];
        if (error) {
            NSLog(@"Unable to clear");
            NSLog(@"%@, %@", error, error.localizedDescription);
            success = NO;
        }
    }
    
    return success;
}

//retrive the managedobjectcontext from the app delegate
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end
