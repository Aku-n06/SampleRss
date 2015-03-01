//
//  DetailViewController.h
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import <UIKit/UIKit.h>


/*This class manage the content of a webview, loading a specified webpage froma  given url
with a back and reload buttons. */
@interface DetailViewController : UIViewController <UIWebViewDelegate>{
    //the BOOL and the timer are used to create a fake loading info, just tu give a good
    //looking feedback to the user that the webpage is being loaded
    BOOL loadingComplete;
    NSTimer *animateProgressTimer;
}




//the string-url of the website that will be loaded automatically at startup
@property (nonatomic) NSString *urlString;
//user interface elements
@property (nonatomic) IBOutlet UIWebView *webPage;
@property (nonatomic) IBOutlet UIProgressView *progressLoadingPage;

//this load a webpage from a given url
-(void)showWebPageWithUrl:(NSString *)urlString;
//open the source page in safari
- (IBAction)openInSafari:(id)sender;

@end
