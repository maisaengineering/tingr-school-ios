//
//  AddKid.h
//  mIOSKidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 07/03/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddKid : NSObject
{
    NSString *age;
    NSString *zipcode;
    NSString *kl_id;
    NSString *photograph;
    NSString *fname;
    NSString *mname;
    NSString *lname;
    NSString *nickname;
    NSString *birthdate;
    NSString *gender;
    NSString *address1;
    NSString *address2;
    NSString *city;
    NSString *state;
    NSString *other_basic_details;
    NSString *medicines;
    NSString *food_allergies;
    NSString *medical_issues;
    NSString *special_needs;
    NSString *other_concerns;
    NSDictionary *doctor;
    NSDictionary *dentist;
    NSMutableArray *parents;
    NSMutableDictionary *recent_document;
    NSMutableDictionary *recent_milestone;
}
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *zipcode;
@property (strong, nonatomic) NSString *kl_id;
@property (strong, nonatomic) NSString *photograph;
@property (strong, nonatomic) NSString *fname;
@property (strong, nonatomic) NSString *mname;
@property (strong, nonatomic) NSString *lname;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *birthdate;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *address1;
@property (strong, nonatomic) NSString *address2;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *other_basic_details;
@property (strong, nonatomic) NSString *medicines;
@property (strong, nonatomic) NSString *food_allergies;
@property (strong, nonatomic) NSString *medical_issues;
@property (strong, nonatomic) NSString *special_needs;
@property (strong, nonatomic) NSString *other_concerns;
@property (strong, nonatomic) NSDictionary *doctor;
@property (strong, nonatomic) NSDictionary *dentist;
@property (strong, nonatomic) NSMutableArray *parents;
@property (strong, nonatomic) NSMutableDictionary *recent_document;
@property (strong, nonatomic) NSMutableDictionary *recent_milestone;

@end
