//
//  TaggingUtils.h
//  KidsLink
//
//  Created by Dale McIntyre on 2/19/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaggingUtils : NSObject

+(NSArray *)getAllTaggedIds:(NSAttributedString *)stringToFormat :(NSArray *)people;

//format string for server
+(NSString *)formatStringForServer:(NSAttributedString *)stringToFormat :(NSArray *)personsNames;

//format string from server
+(NSString *)formatStringFromServer:(NSString *)stringToFormat;

//version with new double tags
+(NSString *)formatAttributedStringFromServerDoubleTags:(NSString *)stringToFormat;

@end
