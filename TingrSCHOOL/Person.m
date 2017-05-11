//
//  Person.m
//  AddressHandling
//
//  Created by Maisa Solutions Pvt Ltd on 05/03/14.
//  Copyright (c) 2014 Maisa Solutions Pvt Ltd. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize firstName;
@synthesize lastName;
@synthesize fullName;
@synthesize homeEmail;
@synthesize workEmail;
@synthesize arrayPhoneNumbers;

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        arrayPhoneNumbers = [NSMutableArray array];
    }
    return self;
}

-(void)dealloc
{
    firstName = nil;
    lastName = nil;
    fullName = nil;
    homeEmail = nil;
    homeEmail = nil;
    workEmail = nil;
    arrayPhoneNumbers = nil;
}


@end
