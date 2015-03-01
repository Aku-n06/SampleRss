//
//  UIWebImageView.m
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "UIWebImageView.h"

@implementation UIWebImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)getPictureFromUrl:(NSString *)stringUrl {
    //try to load picture from the remporary directory
    NSString *formattetName = [stringUrl stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *fileName=[NSString stringWithFormat:@"picture_%@.jpg",formattetName];
    NSString *fileURL = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
        //the image exists so I load and show the image
        UIImage *image =[UIImage imageNamed:fileURL];
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, image.size.height)];
        [self addSubview:imageView];
        imageView.image=image;
    }
    else {
        //download the picture from the web
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = [NSURL URLWithString:stringUrl];
        task = [session downloadTaskWithURL:url completionHandler:
                ^(NSURL *location, NSURLResponse *response, NSError *error) {
                    if (error == nil) {
                        //retrieve the data from disk
                        NSData *imageData = [[NSData alloc] initWithContentsOfURL:location];
                        UIImage *image = [UIImage imageWithData:imageData];
                        image=[self imageWithImage:image scaledToWidth:100];
                        
                        //save the picture on temp directory
                        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
                        NSString *formattetName = [stringUrl stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                        NSString *fileName=[NSString stringWithFormat:@"picture_%@.jpg",formattetName];
                        NSString *fileURL = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                        if (![data2 writeToFile:fileURL atomically:YES]) {
                            //error saving the picture data
                        }
                        
                        //clear cache
                        [[NSURLCache sharedURLCache] removeAllCachedResponses];
                        
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
}

//this method resize the picture height (used to keep the width to 100 px)
-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) width {
    
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
