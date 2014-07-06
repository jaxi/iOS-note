//
//  NoteViewController.m
//  Notes
//
//  Created by Jingkai He on 23/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.note.title;
    
    self.noteTitle.text = self.note.title;
    self.noteContent.text = self.note.content;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.note.title = self.noteTitle.text;
    self.note.content = self.noteContent.text;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.editing) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NotePreview"]) {
        MarkdownPreviewController *mpc = (MarkdownPreviewController *)segue.destinationViewController;
        
        [mpc setHtmlContentWithMarkdownContent:self.noteContent.text];
        mpc.title = self.noteTitle.text;
    }
}

@end
