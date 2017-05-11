//
//  KLTextFormatter.h
//  KidsLink
//
//  Created by Dale McIntyre on 1/23/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLTextFormatter : NSObject

+(NSMutableAttributedString*)formatTextString:(NSString*)serverStringWithTags;

@end
