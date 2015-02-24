/*!
 * ListTableViewController.h
 * MCTObjectStore
 *
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 2/23/15
 */

#ifndef MCTObjectStore_ListTableViewController_h
#define MCTObjectStore_ListTableViewController_h

@import UIKit;
@import MCTObjectStore;

@interface ListTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *results;

- (IBAction)addButtonAction:(id)sender;

@end

#endif
