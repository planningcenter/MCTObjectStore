/*!
 * ListTableViewController.m
 * MCTObjectStore
 *
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 2/23/15
 */

#import "ListTableViewController.h"
#import "Item.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController

- (NSFetchedResultsController *)results {
    if (!_results) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Item className]];
        fetchRequest.sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]
                                  ];
        fetchRequest.fetchBatchSize = 30;
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[[MCTObjectStack sharedStack] mainContext] context] sectionNameKeyPath:nil cacheName:nil];
        controller.delegate = self;
        
        NSError *error = nil;
        if (![controller performFetch:&error]) {
            NSLog(@"Fetch Error: %@",error);
        }
        _results = controller;
    }
    return _results;
}

// MARK: - Actions
- (IBAction)addButtonAction:(id)sender {
    UITextField __block *nameField = nil;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Item", nil) message:NSLocalizedString(@"Create a new item:", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        nameField = textField;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (nameField.text.length == 0) {
            return;
        }
        [[[MCTObjectStack sharedStack] mainContext] performInDisposable:^(NSManagedObjectContext *ctx) {
            Item *item = [Item insertIntoContext:ctx];
            item.name = nameField.text;
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.results.sections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> info = self.results.sections[section];
    return [info numberOfObjects];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    [self configureCell:cell indexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item *item = [self.results objectAtIndexPath:indexPath];
        [item destroy];
        [[[MCTObjectStack sharedStack] mainContext] save:NULL];
    }
}

// MARK: - Configure
- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    Item *item = [self.results objectAtIndexPath:indexPath];
    
    if (item.completedAt) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [item.createdAt description];
}

// MARK: -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Item *item = [self.results objectAtIndexPath:indexPath];
    if (item.completedAt) {
        item.completedAt = nil;
    } else {
        item.completedAt = [NSDate date];
    }
    [[[MCTObjectStack sharedStack] mainContext] save:NULL];
}

// MARK: - Fetch Delegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
