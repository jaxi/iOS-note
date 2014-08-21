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
    
    // Delegate the managedObjectContext from main thread
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // UI Initialisation
    self.navigationItem.title = self.note.title;

    self.noteContent.text = self.note.content;
    
    // Delegate the content of node and tool bar
    [self.noteContent setDelegate:self];
    
    [self setToolbarItemsForKeyboard];
    
    // Notification communication
    [self observeNotifications];
}

/*
 * Keyboard appear and disappear observers
 */
- (void)observeNotifications
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

/*
 * Initialise the tool bar
 */
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

/*
 * Lazy load the threading pool
 */
- (dispatch_queue_t) renderingQueue
{
    if (!_renderingQueue) {
        _renderingQueue = dispatch_queue_create("rendering queue", NULL);
    }
    
    return _renderingQueue;
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

        // Translate the markdown to html in the background;
        // Won't block the animation
        dispatch_async(self.renderingQueue, ^{
            
            NSString *title = [self getPlainTitle:self.note.content];
            
            Document *doc = [[Document alloc]
                             initWithContent:self.noteContent.text];
            Parser *parser = [[Parser alloc] initWithDocument:doc];
            
            [parser parse];
            
            // Join the main thread after computation, ar the rendered content won't be displayed
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *htmlContent = [NSString stringWithFormat:@"<style type='text/css'>@import url('markdown.css');</style>\n%@", [parser render]];
                
                NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];

                mpc.title = title;
                [(UIWebView *)mpc.view
                 loadHTMLString:htmlContent baseURL:baseURL];
            });
        });
    }
}

/*
 * The keyboard will dismiss if finger touch outside the keyboard.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/*
 * Picture taking action
 */
- (IBAction)takePicture :(id)sender
{

    NSLog(@"Take a picture");
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

/*
 * Load picture from the library
 */
- (IBAction)loadPictureFromLibrary :(id)sender
{
    NSLog(@"Load A picture");
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

/*
 * Keyboard dismiss action
 */
- (IBAction)doneClicked :(id)sender
{
    [self.view endEditing:YES];
}

/*
 * Video loading, not implemented yet
 */
- (IBAction)loadVideoFromLibrary:(id)sender
{
    NSLog(@"load video from library");
    [self.view endEditing:YES];
}

/*
 * Video recording, not implemented yet
 */
- (IBAction)takeVideo:(id)sender
{
    NSLog(@"Take video...");
    [self.view endEditing:YES];
}

/*
 * Save the image to the app directory
 */
- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Unique ID generation
    NSUUID  *UUID = [NSUUID UUID];
    NSString* stringUUID = [UUID UUIDString];
    
    // Compress the image
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    // Get the app directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];

    // Image generation
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", stringUUID];
    NSString *savePath = [documentPath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:savePath atomically:YES];
    
    // Generate the markdown content
    NSString *markdownContent = [NSString stringWithFormat:@"![%@](Your Comment)", savePath];

    // Insert it to the document
    NSRange cursorPosition = [self.noteContent selectedRange];
    NSMutableString *targetContent = [[NSMutableString alloc] initWithString:[self.noteContent text]];
    [targetContent insertString:markdownContent atIndex:cursorPosition.location];
    [self.noteContent setText:targetContent];
    
    // Complete the UI animation
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
 * UI animation of keyboard appearing
 */
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

/*
 * UI animation of keyboard dismiss
 */

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

/*
 * The application do not need to set title explicitly. 
 * The first parsed plain text would be the title.
 */
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
        
        // Strip the text
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
