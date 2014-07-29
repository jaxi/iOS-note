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

    UIBarButtonItem *imageLibraryButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Load Picture"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(loadPictureFromLibrary:)];

    UIBarButtonItem *photoTakingButton = [[UIBarButtonItem alloc]
                                          initWithTitle:@"Take Picture"
                                          style:UIBarButtonItemStyleBordered
                                          target:self
                                          action:@selector(takePicture:)];
    
    
    UIBarButtonItem *videoLibraryButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Load Video"
                                           style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(loadVideoFromLibrary:)];

    UIBarButtonItem *videoTakingButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Take Video"
                                           style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(takeVideo:)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(doneClicked:)];
    
    keyboardToolBar.items = @[doneButton, imageLibraryButton,
                              photoTakingButton, videoLibraryButton, videoTakingButton];
    
    self.noteContent.inputAccessoryView = keyboardToolBar;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.note.title = [self getPlainTitle:self.noteContent.text];
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
        
        mpc.title = [self getPlainTitle:self.note.content];
        [mpc setHtmlContentWithMarkdownContent:self.noteContent.text];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)takePicture :(id)sender
{

    NSLog(@"Take a picture");
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)loadPictureFromLibrary :(id)sender
{
    NSLog(@"Load A picture");
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}


- (IBAction)doneClicked :(id)sender
{
    NSLog(@"Done done");
    [self.view endEditing:YES];
}

- (IBAction)loadVideoFromLibrary:(id)sender
{
    NSLog(@"load video from library");
    [self.view endEditing:YES];
}

- (IBAction)takeVideo:(id)sender
{
    NSLog(@"Take video...");
    [self.view endEditing:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    NSUUID  *UUID = [NSUUID UUID];
    NSString* stringUUID = [UUID UUIDString];
    
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];

    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", stringUUID];
    NSString *savePath = [documentPath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:savePath atomically:YES];
    
    NSString *markdownContent = [NSString stringWithFormat:@"![%@](Your Comment)", savePath];

    NSRange cursorPosition = [self.noteContent selectedRange];
    NSMutableString *targetContent = [[NSMutableString alloc] initWithString:[self.noteContent text]];
    [targetContent insertString:markdownContent atIndex:cursorPosition.location];
    [self.noteContent setText:targetContent];
    [self dismissViewControllerAnimated:YES completion:NULL];
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

- (NSString *)getPlainTitle: (NSString *)content
{
    
    NSArray *contentArray = [content
                              componentsSeparatedByString:@"\n"];
    
    for (NSString *markdownTitle in contentArray) {
        Document *doc = [[Document alloc]
                         initWithContent:markdownTitle];
        
        Parser *parser = [[Parser alloc] initWithDocument:doc];
        [parser parse];
        
        NSString *title = [parser render];
        NSRange r;
        while ((r = [title rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
            title = [title stringByReplacingCharactersInRange:r withString:@""];
        }
        
        if (title.length > 0) {
            return title;
        }
    }
    
    return @"No Title";
}
@end
