//
//  LocationUpdatesViewController.h
//  LocationUpdates
//
//  Created by Anton Rogov on 2/10/11.
//  Copyright 2011 Flatsourcing. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LocationsViewController : UITableViewController<NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *context;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *context;

- (void)reload;

@end
