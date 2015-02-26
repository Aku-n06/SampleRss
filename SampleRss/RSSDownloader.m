//
//  RSSDownloader.m
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "RSSDownloader.h"

@implementation RSSDownloader

@synthesize delegate;

+ (id)sharedManager {
    static RSSDownloader *sharedRssDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //initialize the class just one time
        sharedRssDownloader=[[self alloc]init];
    });
    return sharedRssDownloader;
}

-(id)init {
    if(self == [super init]){
        //initialize
        isDownloading=false;
    }
    return self;
}

//start the parsing of a rss data
-(void)getRssFromUrl:(NSURL *)sourceUrl{
    //ceck if it's already processing data, this class perform only one download at time
    if(isDownloading==false){
        isDownloading=true;
        //dowload the rss asynchronously
        NSURLRequest *sourceURLRequest =
        [NSURLRequest requestWithURL:sourceUrl];
        [NSURLConnection sendAsynchronousRequest:sourceURLRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error != nil) {
                                       isDownloading=false;
                                       //respond to connection error
                                        #warning implement network error
                                   }else{
                                       //success, analize the data downloaded
                                       parser = [[NSXMLParser alloc] initWithData:data];
                                       [parser setDelegate:self];
                                       [parser setShouldResolveExternalEntities:NO];
                                       [parser parse];
                                   }
                               }];
    }
    
}

#pragma mark - Parser

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{

    if ([elementName isEqualToString:@"item"]){
        //it's a new item
        currentItem = [[NSRssItem alloc] init];
    }
    else if ([elementName isEqualToString:@"media:thumbnail"]||[elementName isEqualToString:@"image"]){
        currentItem.mediaPictureUrl=[attributeDict valueForKey:@"url"];;
    }
    else{
        //it's a new attribute
        currentAttribute = [[NSMutableString alloc] init];
    }
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    //save the parse element
    if([elementName isEqualToString:@"item"]){
        //[feeds addObject:[currentItem copy]];
    }
    //add to the Article the attributes
    if([elementName isEqualToString:@"title"]){
        currentItem.titleText = currentAttribute;
    }else if([elementName isEqualToString:@"pubDate"]||[elementName isEqualToString:@"date"]){
        currentItem.upDate = currentAttribute;
    }else if([elementName isEqualToString:@"description"]){
        currentItem.descriptionText = currentAttribute;
    }else if([elementName isEqualToString:@"link"]){
        currentItem.sourceUrl = currentAttribute;
    }else if([elementName isEqualToString:@"item"]){
        //finisced loading an item
        //comunicate data using notification
        assert([NSThread isMainThread]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadedItemNotify" object:self userInfo:@{@"rssItemResultsKey":currentItem}];
        //comunicate data using delegate
        //[delegate rssDownloaderGotItem:currentItem];
    }
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    //load the string value of the element
    if(currentAttribute != nil){
        [currentAttribute appendString:string];
    }
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    //finished
    isDownloading=false;
}

@end
