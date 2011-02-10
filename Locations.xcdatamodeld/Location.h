//
//  Location.h
//  Locations
//
//  Created by Anton Rogov on 2/10/11.
//  Copyright 2011 Flatsourcing. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Location :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSDate *timestamp;

@end



