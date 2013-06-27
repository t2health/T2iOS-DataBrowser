//
//  RecordItemCell.h
//  DataBrowser
//
//  Created by Tim Brooks on 6/27/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* keyLabel;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;

@end
