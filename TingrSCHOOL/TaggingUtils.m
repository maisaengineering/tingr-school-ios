//
//  TaggingUtils.m
//  KidsLink
//
//  Created by Dale McIntyre on 2/19/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import "TaggingUtils.h"

@implementation TaggingUtils

//format string for server
+(NSArray *)getAllTaggedIds:(NSAttributedString *)stringToFormat :(NSArray *)people
{
    
    NSMutableArray *taggedIds = [[NSMutableArray alloc]init];
    
    //for each attributed string replace with kl_id
    NSMutableAttributedString *newAttrString = [stringToFormat mutableCopy];
    
    //first replace our special chars just in case
    [[newAttrString mutableString] replaceOccurrencesOfString:@"::" withString:@"||" options:NSCaseInsensitiveSearch range:NSMakeRange(0, newAttrString.string.length)];
    
    [newAttrString beginEditing];
    
    [newAttrString enumerateAttributesInRange:NSMakeRange(0, newAttrString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange attrRange, BOOL *stop)
     {
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         
         UIFont *currentFont = [mutableAttributes objectForKey:@"NSFont"];
         
         if ([[currentFont fontName] isEqualToString:@"HelveticaNeue-Medium"])
         {
             NSString *name = [newAttrString.string substringWithRange:attrRange];
             
             //for each name in personsNames (matched names)
             for (NSDictionary *object in people)
             {
                 // get name and kl_id out of object
                 NSString *person_name = [object objectForKey:@"name"];
                 
                 NSString *kl_id = [object objectForKey:@"kl_id"];
                 
                 if ([[person_name lowercaseString] isEqualToString:[name lowercaseString]])
                 {
                    [taggedIds addObject:kl_id];
                     break;
                 }
                 
             }

         }
     }];
    
    [newAttrString endEditing];
    
    return taggedIds;
    
}


//format string for server
+(NSString *)formatStringForServer:(NSAttributedString *)stringToFormat :(NSArray *)personsNames
{
    //for each attributed string replace with kl_id
    NSMutableAttributedString *newAttrString = [stringToFormat mutableCopy];
    
    //first replace our special chars just in case
    [[newAttrString mutableString] replaceOccurrencesOfString:@"::" withString:@"||" options:NSCaseInsensitiveSearch range:NSMakeRange(0, newAttrString.string.length)];
 
    [newAttrString beginEditing];
    
    [newAttrString enumerateAttributesInRange:NSMakeRange(0, newAttrString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange attrRange, BOOL *stop)
    {
        NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         
         UIFont *currentFont = [mutableAttributes objectForKey:@"NSFont"];
         
         if ([[currentFont fontName] isEqualToString:@"HelveticaNeue-Medium"])
         {
             NSString *name = [newAttrString.string substringWithRange:attrRange];
             
             //for each name in personsNames (matched names)
             for (NSDictionary *object in personsNames)
             {
                 // get name and kl_id out of object
                 NSString *person_name = [object objectForKey:@"name"];
                 
                 NSString *kl_id = [object objectForKey:@"kl_id"];
                 
                 NSString *combined = [NSString stringWithFormat:@"%@::%@::", name, kl_id];
                 
                 // append name in string with ::kl_id (if it is blue) (or we can leave @ in front)
                 if ([[person_name lowercaseString] isEqualToString:[name lowercaseString]])
                 {
                     [[newAttrString mutableString] replaceOccurrencesOfString:name withString:combined options:NSCaseInsensitiveSearch range:NSMakeRange(0, newAttrString.string.length)];
                     break;
                 }
                 
             }
         }
     }];
    
    [newAttrString endEditing];
    
    NSString *stringToReturn = newAttrString.string;
    return stringToReturn;
    
}

//format string from server
+(NSString *)formatStringFromServer:(NSString *)stringToFormat
{
    //for now we are just stripping the kl_id
    // Setup what you're searching and what you want to find
    NSMutableString *finalString = [stringToFormat mutableCopy];
    NSString *string = finalString;
    NSString *toFind = @"::";
   
    // Initialise the searching range to the whole string
    NSRange searchRange = NSMakeRange(0, [string length]);
    do {
        // Search for next occurrence
        NSRange range = [string rangeOfString:toFind options:0 range:searchRange];
        
        if (range.location != NSNotFound)
        {
            //TODO: for next version, I will replace with a custom regex
            NSRange range2= NSMakeRange(range.location, 38);
            finalString = [[finalString stringByReplacingCharactersInRange:range2 withString:@""] mutableCopy];
            string = finalString;
            
            // Reset search range for next attempt to start after the current found range
            searchRange.location = 0;
            searchRange.length = [string length];
        }
        else
        {
            // If we didn't find it, we have no more occurrences
            break;
        }
    } while (1);
    
    return finalString;
}

+(NSString *)formatAttributedStringFromServerDoubleTags:(NSString *)stringToFormat
{
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\::(.*?)\\::" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    //NSString *input = @"::db1::+::db2::+::db3::";
    
    NSArray *myArray = [regex matchesInString:stringToFormat options:0 range:NSMakeRange(0, [stringToFormat length])] ;
    
    //This regex captures all items between []
    for (NSTextCheckingResult *match in myArray)
    {
        NSRange matchRange = [match rangeAtIndex:1];
        //[matches addObject:[input substringWithRange:matchRange]];
        NSLog(@"%@", [stringToFormat substringWithRange:matchRange]);
    }
    
    return stringToFormat;
}



@end
