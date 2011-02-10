//
//  LocationsAppDelegate.m
//  Locations
//
//  Created by Anton Rogov on 2/10/11.
//  Copyright 2011 Flatsourcing. All rights reserved.
//

#import "LocationsAppDelegate.h"
#import "LocationsViewController.h"
#import "Location.h"


@implementation LocationsAppDelegate

@synthesize window;
@synthesize navigation;
@synthesize toggleButton;
@synthesize viewController;


- (void)createLocationUpdate:(NSString *)text date:(NSDate *)date {
	NSManagedObjectContext *context = [self managedObjectContext];
	Location *update = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
														   inManagedObjectContext:context];
	update.location = text;
	update.timestamp = date;
	
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"couldn't save: %@", [error localizedDescription]);
	}
	
	[viewController reload];
}


- (void)startLocationUpdates {
	locationManager = [CLLocationManager new];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startMonitoringSignificantLocationChanges];
	toggleButton.title = @"Stop";
}


- (void)stopLocationUpdates {
	if (locationManager) {
		[locationManager stopMonitoringSignificantLocationChanges];
		[locationManager release];
		locationManager = nil;
	}
	toggleButton.title = @"Start";
}


- (IBAction)clearUpdates {
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *request = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
											  inManagedObjectContext:context];
	[request setEntity:entity];
	NSArray *result = [context executeFetchRequest:request error:nil];
	for (id object in result) {
		[context deleteObject:object];
	}
	[request release];
	
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"couldn't save: %@", [error localizedDescription]);
	}
	
	[viewController reload];
}


- (IBAction)toggleLocationUpdates {
	if (locationManager) {
		[self stopLocationUpdates];
	} else {
		[self startLocationUpdates];
	}
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	if (launchOptions == nil) {
		viewController.context = [self managedObjectContext];
		[window addSubview:navigation.view];
		[self.window makeKeyAndVisible];
		[self startLocationUpdates];
	} else if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
		[self startLocationUpdates];
	}
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)saveContext {
	
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Location callbacks

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSString *update = [NSString stringWithFormat:@"%+f %+f (±%.02f)",
						newLocation.coordinate.latitude,
						newLocation.coordinate.longitude,
						newLocation.horizontalAccuracy];
	[self createLocationUpdate:update date:newLocation.timestamp];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	//	if ([error code] == kCLErrorDenied) {
	//		[self stopLocationUpdates];
	//	}
	[self createLocationUpdate:[error localizedDescription] date:[NSDate date]];
	NSLog(@"error %@", [error localizedDescription]);
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [NSManagedObjectContext new];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Locations" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Locations.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
	[viewController release];
    [window release];
    [super dealloc];
}


@end

