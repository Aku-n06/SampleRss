//
//  RSSItem.h
//  OpenRssReader
//
//  Created by Alberto Scampini on 17/01/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//this class store the information of an Item of an rss feed
@interface RSSItem : NSObject

//the title of the item
@property (nonatomic, retain) NSMutableString * titleText;
//the up date of the item
@property (nonatomic, retain) NSMutableString * upDate;
//the description of the item
@property (nonatomic, retain) NSMutableString * descriptionText;
//the web url for a source article
@property (nonatomic,retain) NSMutableString *sourceUrl;
//the url for the media picture
@property (nonatomic,retain) NSMutableString *mediaPictureUrl;

@end
