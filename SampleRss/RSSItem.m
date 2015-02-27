//
//  RSSItem.m
//  OpenRssReader
//
//  Created by Alberto Scampini on 17/01/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "RSSItem.h"

@implementation RSSItem

@synthesize titleText;
@synthesize upDate;
@synthesize descriptionText;
@synthesize sourceUrl;
@synthesize mediaPictureUrl;


-(id)init{
    if ((self = [super init])) {
        titleText = nil;
        upDate = nil;
        descriptionText = nil;
        sourceUrl = nil;
        mediaPictureUrl = nil;
    }
    return self;
}

@end
