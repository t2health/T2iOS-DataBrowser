//
//  T2MasterViewController.m
//  DataBrowser
//
//  Created by Tim Brooks on 6/26/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BMRecord.h"
#import "T2Styler.h"

@interface MasterViewController ()

@property (nonatomic, strong) NSMutableDictionary* appItems;
@property (nonatomic, strong) NSOrderedSet* appNames;

@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(performDataRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"No Records Loaded";
}
- (NSArray*)sortRecordList:(NSArray*)list byKey:(NSString*)key
{
    
    // first sort list by app name
    NSArray* tempList = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult comparison = NSOrderedSame;
        BMRecord* record1 = (BMRecord*)obj1;
        BMRecord* record2 = (BMRecord*)obj2;
        
        if (record1 && record2) {
            NSString* stringValue1 = (NSString*)[record1 valueForKey:key];
            NSString* stringValue2 = (NSString*)[record2 valueForKey:key];
            
            // only works for strings
            if (stringValue1 && stringValue2) {
                comparison = [stringValue1 localizedCaseInsensitiveCompare:stringValue2];
            }
        }
               
        return comparison;
    }];
    
    return tempList;
}
- (NSOrderedSet*)appNames
{
    if (!_appNames) {
        _appNames = [[NSOrderedSet alloc] init];
    }
    
    return _appNames;
}
- (NSMutableDictionary*)appItems
{
    if (!_appItems) {
        _appItems = [NSMutableDictionary dictionary];
    }
    
    return _appItems;
}
// This methods sets up our TableView data source(s) from the raw
// entry data
- (void)configureAppData:(NSArray*)rawItems
{
    NSString* mainKey = @"appName";
    
    // First, sort records by appName
    NSArray* sortedItemList = [self sortRecordList:rawItems byKey:mainKey];
    
    // Next, create our section names (app names)
    self.appNames = [[NSOrderedSet alloc] initWithArray:[sortedItemList valueForKey:mainKey]];
    
    // Finally, initialize the dictionary of appName/entries
    NSPredicate* namePredicate;
    for (NSString* name in self.appNames) {
        namePredicate = [NSPredicate predicateWithFormat:@"SELF.appName == %@", name];
        self.appItems[name] = [rawItems filteredArrayUsingPredicate:namePredicate];
    }
}
- (void)toggleRefreshButton
{
    UIBarButtonItem* button = self.navigationItem.rightBarButtonItem;
    [button setEnabled:!button.isEnabled];
}
- (void)performDataRefresh
{
    [self toggleRefreshButton];
    self.title = @"...loading...";
    [self.dataStore loadAllRowsWithCompletion:^(NSArray *items, NSError *error) {
        if (!error && items) {
            if (items) {
                [self configureAppData:items];
                [self.tableView reloadData];
            }
        }
        [self toggleRefreshButton];
        [self.refreshControl endRefreshing];
        self.title = [NSString stringWithFormat:@"%d Records", [items count]];

    }];
}
- (IBAction)refreshData:(id)sender
{
    // start refresh
    [self.refreshControl beginRefreshing];
    
    // BUG FIX: Apple doesn't offset table when calling refresh programmatically
    if (self.tableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            
        } completion:^(BOOL finished){
            
        }];
        
    }
    [self performDataRefresh];
}
- (BMRecord*)recordAtIndexPath:(NSIndexPath*)path
{
    NSString* app = self.appNames[path.section];
    NSArray* items = self.appItems[app];
    BMRecord* record = (BMRecord*)items[path.item];
    
    return record;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BMRecord* record = [self recordAtIndexPath:indexPath];
        [[segue destinationViewController] setRecord:record];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BMRecord* record = [self recordAtIndexPath:indexPath];
    cell.textLabel.text = record.timeStamp;
    [T2Styler setFontForView:cell.textLabel ofSize:T2FontSizeMedium];
    
    if (indexPath.item % 2 == 0) {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    } else {
        cell.textLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.appNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* items = self.appItems[self.appNames[section]];
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.appNames[section];
}
@end
