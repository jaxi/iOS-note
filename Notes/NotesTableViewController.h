//
//  NotesTableViewController.h
//  Notes
//
//  Created by Jingkai He on 23/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface NotesTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *notes;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
