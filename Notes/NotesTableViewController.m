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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *note = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:note];
    self.notes = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
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

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
