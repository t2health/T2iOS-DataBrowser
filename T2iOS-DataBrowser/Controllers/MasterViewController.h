//
//  T2MasterViewController.h
//  DataBrowser
//
//  Created by Tim Brooks on 6/26/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "T2DataStore.h"

@interface MasterViewController : UITableViewController

@property (nonatomic, strong) id<T2DataStore> dataStore;

@end
