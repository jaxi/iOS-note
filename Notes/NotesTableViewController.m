//
//  NotesTableViewController.m
//  Notes
//
//  Created by Jingkai He on 23/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "NotesTableViewController.h"
#import "NoteViewController.h"

@interface NotesTableViewController ()

@property (nonatomic, copy) NSMutableArray *notes;

@end

@implementation NotesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)notes
{
    if (! _notes) {
        _notes = [NSMutableArray array];
        
        Note *note = [[Note alloc] initWithTitle:@"Example" content:@"Hello World!"];
        
        [_notes addObject:note];
    }
    
    return _notes;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteTitleTableViewCell" forIndexPath:indexPath];
    
    Note *note = self.notes[indexPath.row];
    cell.textLabel.text = note.title;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notes count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewNote"]) {
        Note *note = [[Note alloc] init];
        
        [self.notes addObject:note];
        
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        
        NoteViewController *nvc = (NoteViewController *)nc.topViewController;
        
        nvc.note = note;
        nvc.editing = NO;
    }
    else if ([segue.identifier isEqualToString:@"EditingNote"]){
        NSIndexPath *ip = [self.tableView indexPathForCell:sender];
        Note *note = self.notes[ip.row];
        
        NSLog(@"%@", note.title);
        
        NoteViewController *nvc = (NoteViewController *)segue.destinationViewController;
        
        nvc.note = note;
        nvc.editing = YES;
    }
}

@end
