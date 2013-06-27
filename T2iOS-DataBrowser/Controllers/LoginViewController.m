//
//  LoginViewController.m
//  DataBrowser
//
//  Created by Tim Brooks on 6/26/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "T2Styler.h"
#import "T2UserStore.h"
#import "T2DataStore.h"
#import "DynamoStore.h"

#define SHOW_RECORDS_SEGUE @"showRecords"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *showDataButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configure];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)configure
{
    // Customize buttons
    [T2Styler styleButton:self.loginButton usingSize:15.0];
    [T2Styler styleButton:self.showDataButton usingSize:15.0];
    [self.showDataButton setTitle:@"Show Data" forState:UIControlStateNormal];
    
    //[self.viewDataButton setEnabled:NO];
    [self setLoginState];
}
- (void)setLoginState
{
    NSString* title = @"Login";
    BOOL hideShowData = YES;
    
    if ([[T2UserStore sharedStore] currentUserIsAuthorized]) {
        title = @"Logout";
        hideShowData = NO;
    }
    [self.loginButton setTitle:title forState:UIControlStateNormal];
    [self.showDataButton setHidden:hideShowData];
    self.title = title;
}
- (IBAction)login:(id)sender
{
    if ([[T2UserStore sharedStore] currentUserIsAuthorized]) {
        [[T2UserStore sharedStore] signOutUser];
        [self setLoginState];
    } else {
        [self.loginButton setEnabled:NO];
        [[T2UserStore sharedStore] signInUserWithCompletion:^(T2UserInfo *userInfo, NSError *err) {
            [self.loginButton setEnabled:YES];
            [self setLoginState];

            // Nav to details view
            [self performSegueWithIdentifier:SHOW_RECORDS_SEGUE sender:sender];
        }];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SHOW_RECORDS_SEGUE]) {       
        [[segue destinationViewController] setDataStore:[DynamoStore sharedStore]];
    }

}

@end
