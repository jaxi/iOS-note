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
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    [self fetchNotes];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteTitleTableViewCell" forIndexPath:indexPath];
    
    Note *note = [self.notes objectAtIndex:indexPath.row];
    cell.textLabel.text = note.title;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notes count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Note *note = [self.notes objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:note];
        [self.managedObjectContext save:nil];
        
        [self.managedObjectContext
         refreshObject:note mergeChanges:YES];
        
        [self fetchNotes];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewNote"]) {
        Note *note = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Note"
                                           inManagedObjectContext:self.managedObjectContext];
        
        [self.notes addObject:note];
        
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        
        NoteViewController *nvc = (NoteViewController *)nc.topViewController;
        
        nvc.note = note;
        nvc.editing = NO;
    }
    else if ([segue.identifier isEqualToString:@"EditingNote"]){
        NSIndexPath *ip = [self.tableView indexPathForCell:sender];
        
        Note *note = [self.notes objectAtIndex:ip.row];
        
        NoteViewController *nvc = (NoteViewController *)segue.destinationViewController;
        
        nvc.note = note;
        nvc.editing = YES;
    }
}

- (void)fetchNotes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *note = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:note];
    self.notes = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
}
@end
