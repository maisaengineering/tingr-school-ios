//
//  ProfileDateUtils.h
//  KidsLink
//
//  Created by Dale McIntyre on 5/2/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileDateUtils : NSObject

- (NSString *)getAgeFromTwoDates:(NSString *)birthdate;
+ (UIImage *) imageFromColor:(UIColor *)color;
- (NSString *) howMuchTimeHasPassed:(NSString *)postedDate;
- (NSString *) localTimeFromEST:(NSString *)currentDateTime;
- (NSString *) localTimeFromUTC:(NSString *)currentDateTime;
- (NSString*)dailyLanguage:(NSString *)postedDate;
- (NSString *)getChildAgeFromMilestoneCreatedDate:(NSString *)milestoneCreatedDate ChildBirthDate:(NSString *) childBirthDate;
- (NSString *)getUTCFormateDateFromLocalDate:(NSDate *)localDate;
-(NSString*)dailyLanguageForMilestone:(NSString *)postedDate actualTimeZone:(NSString *)timeZone;
-(NSMutableArray *)sortByStringDate:(NSMutableArray *)unsortedArray;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
@end
