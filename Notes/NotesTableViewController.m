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
    self.filteredNotesArray = [NSMutableArray arrayWithCapacity:[self.notes count]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoteTableViewCell" forIndexPath:indexPath];
    Note *note;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        note = [self.filteredNotesArray objectAtIndex:indexPath.row];
    }else{
        note = [self.notes objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = note.title;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredNotesArray count];
    }else{
        return [self.notes count];
    }
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
        NSLog(@"Editing Note...");
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

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    [self.filteredNotesArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    self.filteredNotesArray = [NSMutableArray arrayWithArray:[self.notes filteredArrayUsingPredicate:predicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

@end
