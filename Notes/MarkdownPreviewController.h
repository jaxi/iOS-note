//
//  MarkdownPreviewControllerViewController.h
//  Notes
//
//  Created by Jingkai He on 06/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parser.h"

@interface MarkdownPreviewController : UIViewController

@property (nonatomic, copy) NSString *htmlContent;

- (void)setHtmlContentWithMarkdownContent:(NSString *)markDownContent;

@end
