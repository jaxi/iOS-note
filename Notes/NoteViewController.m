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
    
    [self.noteContent setDelegate:self];
    
    [self setToolbarItemsForKeyboard];
    
    [self setNotificationDelegate];
}

- (void)setNotificationDelegate
{
    NSNotificationCenter *notificationCenter =
    [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    
    [notificationCenter
     addObserver:self
     selector:@selector(keyboardWillDisappear:)
     name:UIKeyboardWillHideNotification object:nil];
}

- (void)setToolbarItemsForKeyboard
{
    UIToolbar* keyboardToolBar = [[UIToolbar alloc] init];
    [keyboardToolBar sizeToFit];

    UIBarButtonItem *imageInsertButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Insert Image"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(insertImage:)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(doneClicked:)];
    
    keyboardToolBar.items = @[doneButton, imageInsertButton];
    self.noteContent.inputAccessoryView = keyboardToolBar;
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

- (IBAction)insertImage :(id)sender
{
    NSLog(@"Done done");
    [self.view endEditing:YES];
}

- (IBAction)doneClicked :(id)sender
{
    NSLog(@"Done done");
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
