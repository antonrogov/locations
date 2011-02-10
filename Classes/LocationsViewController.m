//
//  LocationsViewController.m
//  Locations
//
//  Created by Anton Rogov on 2/10/11.
//  Copyright 2011 Flatsourcing. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"


@implementation LocationsViewController

@synthesize fetchedResultsController;
@synthesize context;


- (NSFetchedResultsController *)fetchedResultsController {
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
														 ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[fetchRequest setFetchBatchSize:20];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																   managedObjectContext:context
																	 sectionNameKeyPath:nil
																			  cacheName:@"Root"];
	fetchedResultsController.delegate = self;
	
	[sort release];
	[fetchRequest release];
	
	return fetchedResultsController;
}


#pragma mark -
#pragma mark View lifecycle

- (void)refresh {
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		NSLog(@"Unresolved error %@", [error localizedDescription]);
	}
}


- (void)reload {
	[self refresh];
	[self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Locations";
	[self refresh];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Location *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = item.location;
	
	NSDateFormatter *format = [NSDateFormatter new];
	[format setDateFormat:@"MMM dd, yyyy HH:mm"];
	cell.detailTextLabel.text = [format stringFromDate:item.timestamp];
	[format release];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	fetchedResultsController = nil;
	context = nil;
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate interface

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
	case NSFetchedResultsChangeInsert:
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		break;		
	case NSFetchedResultsChangeDelete:
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		break;
	case NSFetchedResultsChangeUpdate:
		[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
		break;
	case NSFetchedResultsChangeMove:
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {	
    switch(type) {
	case NSFetchedResultsChangeInsert:
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
		break;
	case NSFetchedResultsChangeDelete:
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
		break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end

