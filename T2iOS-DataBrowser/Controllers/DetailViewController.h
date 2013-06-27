//
//  T2DetailViewController.h
//  DataBrowser
//
//  Created by Tim Brooks on 6/26/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMRecord;

@interface DetailViewController : UIViewController

@property (weak, nonatomic) BMRecord* record;

@end
