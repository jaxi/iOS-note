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
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    self.navigationItem.title = self.note.title;

    self.noteTitle.text = self.note.title;
    self.noteContent.text = self.note.content;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillDisappear:)
     name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.note.title = self.noteTitle.text;
    self.note.content = self.noteContent.text;
    
    [self.managedObjectContext save:nil];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets noteContentInset = self.noteContent.contentInset;
    noteContentInset.bottom += keyboardSize.height;
    self.noteContent.contentInset = noteContentInset;
    
    UIEdgeInsets noteContentScrollInset = self.noteContent.scrollIndicatorInsets;
    noteContentScrollInset.bottom += keyboardSize.height;
    self.noteContent.scrollIndicatorInsets = noteContentScrollInset;
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets noteContentInset = self.noteContent.contentInset;
    noteContentInset.bottom -= keyboardSize.height;
    self.noteContent.contentInset = noteContentInset;
    
    UIEdgeInsets noteContentScrollInset = self.noteContent.scrollIndicatorInsets;
    noteContentScrollInset.bottom -= keyboardSize.height;
    self.noteContent.scrollIndicatorInsets = noteContentScrollInset;
}

@end
