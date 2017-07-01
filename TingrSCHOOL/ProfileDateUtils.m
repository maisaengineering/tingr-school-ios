//
//  ProfileDateUtils.m
//  KidsLink
//
//  Created by Dale McIntyre on 5/2/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "ProfileDateUtils.h"

@implementation ProfileDateUtils

- (NSString *)getAgeFromTwoDates:(NSString *)birthdate
{
    NSString *start = birthdate; //@"2010-09-01";
    NSString *end = [self getTodaysDate];   //@"2010-12-01";

    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSDate *startDate = [f dateFromString:start];
    NSDate *endDate = [f dateFromString:end];

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    int finalDays = (int)[components day];
    
    NSString *dateAsString = [self getFormattedStringForTable:finalDays];
    
    return dateAsString;
}
- (NSString *)getChildAgeFromMilestoneCreatedDate:(NSString *)milestoneCreatedDate ChildBirthDate:(NSString *) childBirthDate
{
    NSString *start = childBirthDate; //@"2010-09-01";
    NSString *end = milestoneCreatedDate;   //@"2010-12-01";
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSDate *startDate = [f dateFromString:start];
    NSDate *endDate = [f dateFromString:end];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    int finalDays = (int)[components day];
    NSString *dateAsString;
    if(finalDays > 0)
       dateAsString = [self age:startDate end:endDate];
        //dateAsString = [self getFormattedStringForTable:finalDays];
    else
        dateAsString = [self getFormattedStringForChildBdayForMilestone:finalDays];
    return dateAsString;
}
//TODO: make sure the two date strings are properly formatted before sending in
//TODO: make a method to do the calcs and wording

-(NSString *)getTodaysDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
    //DebugLog(@"Todays date is = %@",dateString);
}
-(NSString *)getFormattedStringForChildBdayForMilestone:(int)days
{
    days = days*-1;
    NSString *suffix = @"";
    
    if (days == 1)
    {
        suffix = [NSString stringWithFormat:@"1 day before birth"];
    }
    else if(days <= 13)
    {
        suffix = [NSString stringWithFormat:@"%i days before birth",days];
    }
    else if (days < 365)
    {
        suffix = [NSString stringWithFormat:@"%i weeks before birth",days/7];

    }
    else if(days >= 365)
    {
        int years = days/365;
        if(years > 1)
        suffix = [NSString stringWithFormat:@"%i years before birth",days/365];
        else
            suffix = [NSString stringWithFormat:@"%i year before birth",days/365];
    }
    return suffix;
}
-(NSString *)getFormattedStringForTable:(int)days
{
    NSString *suffix = @"";
    NSString *prefix = @"";
    
    if (days <= 1)
    {
        prefix = @"1";
        suffix = @"day old";
    }
    else if (days <= 30)
    {
        prefix = [@(days) stringValue];
        suffix = @"days old";
    }
    else if (days > 30 && days < 60)
    {
        prefix = @"1";
        suffix = @"month old";
    }
    else if (days >= 60 && days < 721)
    {
        int months = (days / 30);
        prefix = [@(months) stringValue];
        suffix = @"months old";
    }
    else if (days >= 720)
    {
        int years = (days / 365);
        if (years == 1)
            suffix = @"year old";
        else
            suffix = @"years old";
        prefix = [@(years) stringValue];
        
    }
    
    NSString *finalAge = [NSString stringWithFormat:@"%@ %@", prefix, suffix];
    
    return finalAge;
    
}
- (NSString *)age:(NSDate *)dateOfBirth end:(NSDate *)end
{
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                       fromDate:dateOfBirth
                                       toDate:end
                                       options:0];
    
    NSString *suffix = @"";
    NSInteger prefix = 0;
    
    if(ageComponents.year > 1)
    {
        prefix = ageComponents.year;
        suffix = @"years old";
    }
    else if(ageComponents.year == 1||ageComponents.month > 0)
    {
        prefix = ageComponents.year*12+ageComponents.month;
        suffix = prefix > 1?@"months old":@"month old";
    }
    else if(ageComponents.day == 1)
    {
        prefix = ageComponents.day;
        suffix = @"day old";
    }
    else  if(ageComponents.day > 1)
    {
        prefix = ageComponents.day;
        suffix = @"days old";
    }
    
    NSString *finalAge = [NSString stringWithFormat:@"%ld %@", (long)prefix, suffix];
    
    return finalAge;
  
    
}
+ (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (NSString *) localTimeFromEST:(NSString *)currentDateTime
{
    
    NSString *dateStr = currentDateTime; // @"05/31/2014 10:57am-0400"; //@"05/30/2014 08:11:00pm UTC";
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" EDT" withString:@"-0400"];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" EST" withString:@"-0500"];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter1 setLocale:enUSPOSIXLocale];
    
    [dateFormatter1 setDateFormat:@"MM/dd/yyyy hh:mmaZZZ"];
    
    NSDate *date = [dateFormatter1 dateFromString:dateStr];
    dateStr = [dateFormatter1 stringFromDate: date];
    DebugLog(@"date : %@",date);
    
    
    //NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    //DebugLog(@"Desitination DateString : %@", destinationDate);
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"MM/dd/yyyy"];
    [dateFormatters setDateStyle:NSDateFormatterShortStyle];
    [dateFormatters setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatters setDoesRelativeDateFormatting:YES];
    [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
    dateStr = [dateFormatters stringFromDate: date];
    
    
    DebugLog(@"DateString : %@", dateStr);
    
    return dateStr;
    
}


- (NSString *) localTimeFromUTC:(NSString *)currentDateTime
{

    NSString *dateStr = currentDateTime; // @"05/31/2014 10:57am-0400"; //@"05/30/2014 08:11:00pm UTC";
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" UTC" withString:@"-0000"];
    //dateStr = [dateStr stringByReplacingOccurrencesOfString:@" EST" withString:@"-0500"];
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    /*
    BOOL isDaylightSavings = timeZone.isDaylightSavingTime;
    if (isDaylightSavings) //AND phone is not Daylight savings anymore
    {
        //dateStr = [dateStr stringByReplacingOccurrencesOfString:@"-0000" withString:@"-0100"];
    }
     */
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setTimeZone:timeZone];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter1 setLocale:enUSPOSIXLocale];
    
    [dateFormatter1 setDateFormat:@"MM/dd/yyyy hh:mmaZZZ"];

    NSDate *date = [dateFormatter1 dateFromString:dateStr];
    dateStr = [dateFormatter1 stringFromDate: date];
    DebugLog(@"date : %@",date);
    
   
    //NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    //DebugLog(@"Desitination DateString : %@", destinationDate);
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"MM/dd/yyyy"];
    //[dateFormatters setDateStyle:NSDateFormatterShortStyle];
    //[dateFormatters setTimeStyle:NSDateFormatterShortStyle];
    //[dateFormatters setDoesRelativeDateFormatting:YES];
    //[dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
    dateStr = [dateFormatters stringFromDate: date];
    
    
    DebugLog(@"DateString : %@", dateStr);
    
    return dateStr;
    
}

- (NSString *) howMuchTimeHasPassed:(NSString *)postedDate
{
    //TODO: test with a hard string to see what happens - maybe put the T in to test
    NSString *dateStr = postedDate; //@"05/30/2014 08:11:00pm UTC"; //postedDate; //@05/30/2014 08:01pm UTC  //:00-05:00
    //NSString *ds = [dateStr stringByReplacingOccurrencesOfString:@"pm UTC" withString:@":00-05:00"];
    
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"MM/dd/yyyy HH:mma ZZZ"]; //'T'HH:mm:ssZZZ"];
    
    
    NSDate *date = [dateFormatter1 dateFromString:dateStr];
    DebugLog(@"date : %@",date);
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
     DebugLog(@"Desitination DateString : %@", destinationDate);
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"MM/dd/yyyy"];
    [dateFormatters setDateStyle:NSDateFormatterShortStyle];
    [dateFormatters setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatters setDoesRelativeDateFormatting:YES];
    [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
    dateStr = [dateFormatters stringFromDate: destinationDate];
    
    DebugLog(@"DateString : %@", dateStr);
    
    
    return dateStr;
    
}
-(NSString*)dailyLanguage:(NSString *)postedDate
{
    NSString *dateStr = postedDate;
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" UTC" withString:@"-0000"];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setTimeZone:timeZone];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter1 setLocale:enUSPOSIXLocale];
    
    [dateFormatter1 setDateFormat:@"MM/dd/yyyy hh:mmaZZZ"];
    
    NSDate *date = [dateFormatter1 dateFromString:dateStr];
    
    NSTimeInterval overdueTimeInterval = [[NSDate date] timeIntervalSinceDate:date];

    if (overdueTimeInterval<0)
        overdueTimeInterval*=-1;
    NSInteger minutes = round(overdueTimeInterval)/60;
    NSInteger hours   = minutes/60;
    NSInteger days    = hours/24;
    //NSInteger months  = days/30;
   // NSInteger years   = months/12;
    NSString* overdueMessage;
     if (days>0)
    {
        if(days > 5)
        {
            [dateFormatter1 setDateFormat:@"MMMM dd, yyyy"];
            overdueMessage = [dateFormatter1 stringFromDate:date];
        }
            else
        overdueMessage = [NSString stringWithFormat:@"%ld %@", (long)(days), (days==1?@"day ago":@"days ago")];
        
    }
    else if (hours>0)
    {
        overdueMessage = [NSString stringWithFormat:@"%ld %@", (long)(hours), (hours==1?@"hour ago":@"hours ago")];
        
    }
    else if (minutes>0)
    {
        overdueMessage = [NSString stringWithFormat:@"%ld %@", (long)(minutes), (minutes==1?@"minute ago":@"minutes ago")];
        
    }
    else if (overdueTimeInterval<60)
    {
        overdueMessage = [NSString stringWithFormat:@"seconds ago"];
    }
    return overdueMessage;
    
}
-(NSString*)dailyLanguageForMilestone:(NSString *)postedDate actualTimeZone:(NSString *)actualtimeZone
{

    
    NSString *dateStr = postedDate;
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" UTC" withString:@"-0000"];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setTimeZone:timeZone];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter1 setLocale:enUSPOSIXLocale];
    
    [dateFormatter1 setDateFormat:@"MM/dd/yyyy hh:mmaZZZ"];

    
    NSString* overdueMessage;
  
///            [dateFormatter1 setTimeZone:[NSTimeZone timeZoneWithName:actualtimeZone]];
            NSDate *date2 = [dateFormatter1 dateFromString:dateStr];
            [dateFormatter1 setDateFormat:@"EEE, MMM d, ''yy 'at' hh:mm a"];
    
    overdueMessage = [dateFormatter1 stringFromDate:date2];

    
    return overdueMessage;
    
}
#pragma mark- UIAlertView Delegate Methods
#pragma mark-
-(NSString *)getUTCFormateDateFromLocalDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //1. Convert Datepicker date to "UTC" time zone date.
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //2. Then Convert UTC date to (MM/dd/yyyy) date
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    // 3. Required formatted string for server communication
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

#pragma mark- Sort Kids Profiles
#pragma mark-
-(NSMutableArray *)sortByStringDate:(NSMutableArray *)unsortedArray
{
    NSMutableArray *tempArray=[unsortedArray mutableCopy];
    
    NSDateFormatter *df=[[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM/dd/yyyy"];
    
    NSInteger counter=[tempArray count];
    NSDate *compareDate;
    NSInteger index;
    for(int i=0;i<counter;i++)
    {
        index=i;
        compareDate=[df dateFromString:[[tempArray objectAtIndex:i] valueForKey:@"birthdate"]];
        NSDate *compareDateSecond;
        for(int j=i+1;j<counter;j++)
        {
            compareDateSecond=[df dateFromString:[[tempArray objectAtIndex:j] valueForKey:@"birthdate"]];
            NSComparisonResult result = [compareDate compare:compareDateSecond];
            if(result == NSOrderedDescending)
            {
                compareDate=compareDateSecond;
                index=j;
            }
        }
        if(i!=index)
            [tempArray exchangeObjectAtIndex:i withObjectAtIndex:index];
    }
    
    [unsortedArray removeAllObjects];
    for(int i=0;i<[tempArray count];)
    {
        
        NSArray *array = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"birthdate = %@",[[tempArray objectAtIndex:i] objectForKey:@"birthdate"]]];
        if(array.count > 1)
        {
            NSSortDescriptor *brandDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"nickname" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            id sortDescriptors1 = [NSArray arrayWithObject:brandDescriptor1];
            NSMutableArray *sortedArray = [[array sortedArrayUsingDescriptors:sortDescriptors1] mutableCopy];
            [unsortedArray addObjectsFromArray:sortedArray];
            i+=array.count;
        }
        else
        {
            [unsortedArray addObject:[tempArray objectAtIndex:i]];
            i++;
        }
    }
    return unsortedArray;
    
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end

