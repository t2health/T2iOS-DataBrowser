//
//  T2Styler.h
//  T2User
//
//  Created by Tim Brooks on 5/31/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <Foundation/Foundation.h>

// Color Macros
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

typedef NS_ENUM(NSInteger, T2FontSize) {
    T2FontSizeTiny = 6,
    T2FontSizeSmall = 8,
    T2FontSizeMedium = 12,
    T2FontSizeLarge = 14,
    T2FontSizeExtraLarge = 18
};

@interface T2Styler : NSObject

+ (void)styleButton:(UIButton*)button usingSize:(T2FontSize)fontSize;
+ (void)setFontForView:(id)view ofSize:(T2FontSize)fontSize;
+ (T2Styler*)sharedInstance;

@end
