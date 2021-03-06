//
//  SavedPinsTVC.m
//  MyFavPins
//
//  Created by Akshay Bharath on 10/31/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "SavedPinsTVC.h"
#import "PinDetailsVC.h"

@interface SavedPinsTVC ()

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (strong, nonatomic) UISearchController *searchController;
@property (retain, nonatomic) UIBarButtonItem *editButton;
@property (retain, nonatomic) UIBarButtonItem *doneButton;

@end

@implementation SavedPinsTVC

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Preserve selection between presentations.
  self.clearsSelectionOnViewWillAppear = NO;
  
  // Cusomize the edit and done buttons
  self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(goEdit:)];
  [self.editButton configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
  [self.editButton setTintColor:[UIColor cloudsColor]];
  self.navigationItem.rightBarButtonItem = self.editButton;
  
  self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneEdit:)];
  [self.doneButton configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
  [self.doneButton setTintColor:[UIColor cloudsColor]];
  
  // Add custom left navi button
  UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Back to Map" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
  [left configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
  [left setTintColor:[UIColor cloudsColor]];
  self.navigationItem.leftBarButtonItem = left;
  
  // Search bar setup
  self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
  self.searchController.dimsBackgroundDuringPresentation = NO;
  self.searchController.searchResultsUpdater = self;
  self.searchController.delegate = self;
  [self.searchController.searchBar sizeToFit];
  self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
  self.tableView.tableHeaderView = self.searchController.searchBar;
  
  // fetch
  NSError *error;
  if (![[self fetchedResultsController] performFetch:&error])
  {
    // Update to handle the error appropriately.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    exit(-1);  // Fail
  }
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyPin" inManagedObjectContext:self.managedObjectContext];
  [[self.fetchedResultsController fetchRequest] setEntity:entity];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
  [[self.fetchedResultsController fetchRequest] setSortDescriptors:[NSArray arrayWithObject:sort]];
  [[self.fetchedResultsController fetchRequest] setFetchBatchSize:20];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  // restore the searchController's active state
  if (self.searchControllerWasActive)
  {
    self.searchController.active = self.searchControllerWasActive;
    self.searchControllerWasActive = NO;
    
    if (self.searchControllerSearchFieldWasFirstResponder)
    {
      [self.searchController.searchBar becomeFirstResponder];
      self.searchControllerSearchFieldWasFirstResponder = NO;
    }
  }
}

- (void)viewDidUnload
{
  self.fetchedResultsController = nil;
  
  if (self.tableView.editing)
  {
    [self.tableView setEditing:NO animated:YES];
  }
  
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

// Pops controller with custom animation
- (void)goBack:(id)sender
{
  [UIView animateWithDuration:0.75 animations:^{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
  }];
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)goEdit:(id)sender
{
  self.tableView.editing = YES;

  // Set the right button
  [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:YES];
}

- (void)doneEdit:(id)sender
{
  self.tableView.editing = NO;

  // Set the right button
  [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:YES];
}

// Fetch the results controller
- (NSFetchedResultsController *)fetchedResultsController
{
  if (_fetchedResultsController != nil)
  {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyPin" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  [fetchRequest setFetchBatchSize:20];
  
  NSFetchedResultsController *theFetchedResultsController =
  [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                      managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                 cacheName:nil];
  
  self.fetchedResultsController = theFetchedResultsController;
  _fetchedResultsController.delegate = self;
  
  return _fetchedResultsController;
}

- (UIBarButtonItem *)rightBarButtonItem
{
  if (self.tableView.editing) {
    return self.doneButton;
  }
  
  return self.editButton;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  NSLog(@"Number of rows: %lu", (unsigned long)[sectionInfo numberOfObjects]);
  return [sectionInfo numberOfObjects];
}

// Configure cell at indexPath
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  MyPin *pin = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = pin.name;
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
  NSString *addedOn = [[NSString alloc]initWithFormat:@"Added on: %@", [df stringFromDate:pin.dateCreated]];
  [cell.detailTextLabel setText:addedOn];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"MainCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  // Set up the cell...
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  MyPin *pin = [self.fetchedResultsController objectAtIndexPath:indexPath];
  PinDetailsVC *pinDetailsVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"pinDetailsVC"];
  pinDetailsVC.pinObject = pin;
  pinDetailsVC.delegate = self;
  pinDetailsVC.indexPathOfObject = indexPath;
  
  [[self.searchController searchBar] resignFirstResponder];
  [self.searchController setActive:NO];
  [self.view endEditing:TRUE];
  
  [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  
  [self.navigationController pushViewController:pinDetailsVC animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete the row from the data source
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.managedObjectContext deleteObject:managedObject];
    [self.managedObjectContext save:nil];
  }
}

#pragma mark - NSFetchedResultsControllerDelegate stuff

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
  UITableView *tableView = self.tableView;
  
  switch(type) {
      
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      break;
      
    case NSFetchedResultsChangeMove:
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
  [self.tableView endUpdates];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController
{
  //NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
  //NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
  NSError *error;
  self.fetchedResultsController = nil;
  if (![[self fetchedResultsController] performFetch:&error])
  {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  
  NSLog(@"Num of items in result set: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects] count]);
  
  [self.tableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
}

#pragma - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
  if (!searchController.isActive)
    return;
  
  // Search text
  NSString *searchText = searchController.searchBar.text;
  
  // strip out all the leading and trailing spaces
  NSString *strippedStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
  [NSFetchedResultsController deleteCacheWithName:nil];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", strippedStr];
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
  [[self.fetchedResultsController fetchRequest] setPredicate:predicate];
  [[self.fetchedResultsController fetchRequest] setSortDescriptors:[NSArray arrayWithObject:sort]];
  [[self.fetchedResultsController fetchRequest] setFetchBatchSize:20];
  
  NSError *error;
  if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  
  NSLog(@"Num of items in result set: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects] count]);
  
  [self.tableView reloadData];
}

@end
