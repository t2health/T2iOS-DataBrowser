//
//  T2DetailViewController.m
//  DataBrowser
//
//  Created by Tim Brooks on 6/26/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "DetailViewController.h"
#import "BMRecord.h"
#import "BMRecordItem.h"
#import "T2Styler.h"
#import "RecordItemCell.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel* appNameVal;
@property (weak, nonatomic) IBOutlet UILabel* countryVal;
@property (weak, nonatomic) IBOutlet UILabel* createdDateVal;
@property (weak, nonatomic) IBOutlet UILabel* dataTypeVal;
@property (weak, nonatomic) IBOutlet UILabel* guidVal;
@property (weak, nonatomic) IBOutlet UILabel* languageVal;
@property (weak, nonatomic) IBOutlet UILabel* platformVal;
@property (weak, nonatomic) IBOutlet UILabel* recordIdVal;
@property (weak, nonatomic) IBOutlet UILabel* sessionDateVal;
@property (weak, nonatomic) IBOutlet UILabel* sessionIdVal;
@property (weak, nonatomic) IBOutlet UILabel* timeStampVal;
@property (weak, nonatomic) IBOutlet UILabel* versionVal;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item
- (void)setRecord:(BMRecord *)record
{
    if (_record != record) {
        _record = record;
        // Update the view
        [self configureView];
    }
}
- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.record) {
        self.appNameVal.text = self.record.appName;
        self.countryVal.text = self.record.country;
        self.createdDateVal.text = self.record.createdDateDescription;
        self.dataTypeVal.text = self.record.dataType;
        self.guidVal.text = self.record.guid;
        self.languageVal.text = self.record.language;
        self.platformVal.text = self.record.platform;
        self.recordIdVal.text = self.record.recordId;
        self.sessionDateVal.text = self.record.sessionDateShortDescription;
        self.sessionIdVal.text = self.record.sessionId;
        self.timeStampVal.text = self.record.timeStamp;
        self.versionVal.text = self.record.version;
        
        self.title = self.record.timeStamp;
        
        [self setFonts];
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_linen"]];
    }
}

- (void)setFonts
{
    for (UIView* view in [self.view subviews]) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)view;
            [T2Styler setFontForView:label ofSize:[label.font pointSize]];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    [self configureView];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.record.items count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMRecordItem* item = self.record.items[indexPath.item];
    RecordItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.keyLabel.text = item.key;
    cell.valueLabel.text = item.description;
    
    [T2Styler setFontForView:cell.keyLabel ofSize:T2FontSizeSmall];
    [T2Styler setFontForView:cell.valueLabel ofSize:T2FontSizeSmall];
    
    return cell;
}
@end
