//
//  NameUtils.m
//  KidsLink
//
//  Created by Jonathan Nesbitt on 5/27/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "NameUtils.h"

@implementation NameUtils

+ (NSString *)firstNameAndLastInitialFromName:(NSString *)name
{
    NSArray *names = [name componentsSeparatedByString:@" "];
    NSString *displayName = names[0];
    if (names.count > 1) {
        NSString *lastInitial = [names[names.count - 1] substringWithRange:NSMakeRange(0, 1)];
        displayName = [NSString stringWithFormat:@"%@ %@", displayName, lastInitial];
    }
    return displayName;
}

+ (NSString *)firstNameAndLastNameFromName:(NSString *)name
{
    NSArray *names = [name componentsSeparatedByString:@" "];
    NSString *displayName = names[0];
    if (names.count > 1) {
        NSString *lastInitial = names[names.count - 1];
        displayName = [NSString stringWithFormat:@"%@ %@", displayName, lastInitial];
    }
    return displayName;
}

@end
