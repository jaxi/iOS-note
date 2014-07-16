//
//  NoteViewController.h
//  Notes
//
//  Created by Jingkai He on 23/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "MarkdownPreviewController.h"

@interface NoteViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *noteTitle;
@property (nonatomic, weak) IBOutlet UITextView *noteContent;

@property (nonatomic) BOOL newNote;
@property (nonatomic) Note *note;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
