//
//  UIWebImageView.m
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "UIWebImageView.h"

@implementation UIWebImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)getPictureFromUrl:(NSString *)stringUrl{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:stringUrl];
    task = [session downloadTaskWithURL:url completionHandler:
                                      ^(NSURL *location, NSURLResponse *response, NSError *error){
                                          if(error == nil){
                                              //retrieve the data from disk
                                              NSData *imageData = [[NSData alloc] initWithContentsOfURL:location];
                                              //save the picture on temp directory
                                              #warning realize the offline cache
                                              UIImage *image = [UIImage imageWithData:imageData];
                                              image=[self imageWithImage:image scaledToWidth:100];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  //show the image
                                                  imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, image.size.height)];
                                                  [self addSubview:imageView];
                                                  imageView.image=image;
                                              });
                                          }
                                      }];
    [task resume];
}

//this method resize the picture height (used to keep the width to 100 px)
-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) width{
    
    float oldWidth = sourceImage.size.width;
    float scaleFactor = width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)dealloc {
    [task cancel]; //in case the URL is still downloading
}

@end
