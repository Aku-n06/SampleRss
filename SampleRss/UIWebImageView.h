//
//  UIWebImageView.h
//  SampleRss
//
//  Created by Alberto Scampini on 27/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <UIKit/UIKit.h>

/* This subclass of UIView provide an image from the web in asynchronous way
 resize it maintaining the aspect ratio with a fixed width of 100px and display
 it in a UIImageView.
 In case of deallocation the url session will be canceled
 */
@interface UIWebImageView : UIView{
    NSURLSessionDownloadTask *task;
    UIImageView *imageView;
}

//this method is called to start the download of an image from a given url
-(void)getPictureFromUrl:(NSString *)stringUrl;

@end
