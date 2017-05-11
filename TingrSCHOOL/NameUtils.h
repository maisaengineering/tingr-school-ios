//
//  NameUtils.h
//  KidsLink
//
//  Created by Jonathan Nesbitt on 5/27/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameUtils : NSObject

+ (NSString *)firstNameAndLastInitialFromName:(NSString *)name;
+ (NSString *)firstNameAndLastNameFromName:(NSString *)name;
@end
