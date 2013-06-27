//
//  T2Styler.m
//  T2User
//
//  Created by Tim Brooks on 5/31/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "T2Styler.h"
#import <QuartzCore/QuartzCore.h>

NSString* const primaryFont = @"OpenSans";
NSString* const secondaryFont = @"OpenSans-Light";
NSString* const boldFont = @"OpenSans-Bold";

@implementation T2Styler

+ (void)styleButton:(UIButton*)button usingSize:(T2FontSize)fontSize
{
    [T2Styler setFontForView:button ofSize:fontSize];
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
}

+ (void)setFontForView:(id)view ofSize:(T2FontSize)fontSize
{
    if ([view respondsToSelector:@selector(setFont:)]) {
        CGFloat size = (CGFloat)fontSize;
        [view setFont:[UIFont fontWithName:primaryFont size:size]];
    }
    if ([view respondsToSelector:@selector(setAdjustsFontSizeToFitWidth:)]) {
        [view setAdjustsFontSizeToFitWidth:YES];
    }
}
+ (T2Styler*)sharedInstance
{
    static dispatch_once_t pred;
    static T2Styler* instance = nil;
    
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
