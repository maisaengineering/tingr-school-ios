//
//  ProfilesList.h
//  mIOSKidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 08/03/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfilesList : NSObject
{
    NSMutableArray      *parents;
    NSMutableArray      *kids;
    NSMutableDictionary *onboarding_partner;
    BOOL vphr;
}
@property (nonatomic, assign)  BOOL vphr;
@property (strong, nonatomic) NSMutableArray      *parents;
@property (strong, nonatomic) NSMutableArray      *kids;
@property (strong, nonatomic) NSMutableDictionary *onboarding_partner;
@end
