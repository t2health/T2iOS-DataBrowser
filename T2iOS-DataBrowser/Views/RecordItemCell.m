//
//  RecordItemCell.m
//  DataBrowser
//
//  Created by Tim Brooks on 6/27/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "RecordItemCell.h"

@implementation RecordItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
