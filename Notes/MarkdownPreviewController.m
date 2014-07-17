//
//  MarkdownPreviewControllerViewController.m
//  Notes
//
//  Created by Jingkai He on 06/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "MarkdownPreviewController.h"

@interface MarkdownPreviewController ()

@end

@implementation MarkdownPreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit =YES;
    
    self.view = webView;
}

- (void)setHtmlContentWithMarkdownContent:(NSString *)markDownContent
{
    Document *doc = [[Document alloc] initWithContent:markDownContent];
    Parser *parser = [[Parser alloc] initWithDocument:doc];
    
    [parser parse];
    
    _htmlContent = [NSString stringWithFormat:@"<style type='text/css'>@import url('markdown.css');</style>\n%@", [parser render]];
    
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [(UIWebView *)self.view loadHTMLString:_htmlContent baseURL:baseURL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
