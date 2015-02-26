//
//  TableViewController.m
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //create the feed array empty
    feeds = [[NSMutableArray alloc] init];
    
    //setup and launch the parser
    NSURL *url = [NSURL URLWithString:@"http://newsrss.bbc.co.uk/rss/sportonline_world_edition/front_page/rss.xml"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}

#pragma mark - Parser

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    //parse the element
    element = elementName;
    if ([element isEqualToString:@"item"]){
        rssItem = [[NSMutableDictionary alloc] init];
        rssTitle = [[NSMutableString alloc] init];
        rssLink = [[NSMutableString alloc] init];
    }
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    //save the parse element
    if([elementName isEqualToString:@"item"]){
        [rssItem setObject:rssTitle forKey:@"title"];
        [rssItem setObject:rssLink forKey:@"link"];
        [feeds addObject:[rssItem copy]];
    }
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if([element isEqualToString:@"title"]){
        [rssTitle appendString:string];
    }
    else if([element isEqualToString:@"link"]){
        [rssLink appendString:string];
    }
        
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self.tableView reloadData];
}

@end
