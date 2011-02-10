//
//  LocationsAppDelegate.h
//  Locations
//
//  Created by Anton Rogov on 2/10/11.
//  Copyright 2011 Flatsourcing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class LocationsViewController;

@interface LocationsAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
    UIWindow *window;
	UINavigationController *navigation;
	UIBarButtonItem *toggleButton;
	LocationsViewController *viewController;
	CLLocationManager *locationManager;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigation;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *toggleButton;
@property (nonatomic, retain) IBOutlet LocationsViewController *viewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

- (void)startLocationUpdates;
- (void)stopLocationUpdates;

- (IBAction)clearUpdates;
- (IBAction)toggleLocationUpdates;

@end

