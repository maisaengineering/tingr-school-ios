//
//  Person.h
//  AddressHandling
//
//  Created by Maisa Solutions Pvt Ltd on 05/03/14.
//  Copyright (c) 2014 Maisa Solutions Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *homeEmail;
@property (nonatomic, strong) NSString *workEmail;
@property (nonatomic, strong) NSMutableArray *arrayPhoneNumbers;
@end
