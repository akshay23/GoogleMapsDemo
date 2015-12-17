//
//  SavedPinsTVC.h
//  MyFavPins
//
//  Created by Akshay Bharath on 10/31/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityMapVC.h"

@class CityMapVC;

@interface SavedPinsTVC : UITableViewController <NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate>

@property (strong, nonatomic) CityMapVC *delegate;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
