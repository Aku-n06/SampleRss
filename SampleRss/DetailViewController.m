//
//  DetailViewController.m
//  SampleRss
//
//  Created by Alberto Scampini on 26/02/15.
//  Copyright (c) 2015 Alberto Scampini. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //set this variable to true before asking to load a page so the progressbar will start the animation
    loadingComplete = true;
    [self showWebPageWithUrl:self.urlString];
}

-(void)showWebPageWithUrl:(NSString *)urlString{
    //remove space from url (some url have a space at the end that invalidate the request)
    NSArray* strings = [urlString componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //create and send the request
    NSURL *websiteUrl = [NSURL URLWithString:[strings objectAtIndex:0]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [self.webPage loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)animateProgressLoadingPage{
    if(loadingComplete){
        if(self.progressLoadingPage.progress >= 1){
            self.progressLoadingPage.hidden = true;
            [animateProgressTimer invalidate];
        }
        else {
            self.progressLoadingPage.progress += 0.1;
        }
    }
    else {
        if(self.progressLoadingPage.progress < 0.95){
            self.progressLoadingPage.progress += 0.005;
        }
    }
}

- (IBAction)openInSafari:(id)sender {
    //remove space from url (some url have a space at the end that invalidate the request)
    NSArray* strings = [self.urlString componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //create and send the request
    NSURL *websiteUrl = [NSURL URLWithString:[strings objectAtIndex:0]];
    [[UIApplication sharedApplication] openURL:websiteUrl];
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    if(loadingComplete == true){
        //start the progressbar animation (60 fps)
        self.progressLoadingPage.hidden = false;
        self.progressLoadingPage.progress = 0;
        loadingComplete = false;
        animateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(animateProgressLoadingPage) userInfo:nil repeats:YES];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    loadingComplete = true;
}



@end
