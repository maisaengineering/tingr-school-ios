//
//  KLTextFormatter.m
//  KidsLink
//
//  Created by Dale McIntyre on 1/23/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import "KLTextFormatter.h"

@implementation KLTextFormatter

+(NSMutableAttributedString*)formatTextString:(NSString*)serverStringWithTags
{
    
   //split sentence into array
    NSArray *arrayOfPositions = [serverStringWithTags componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    arrayOfPositions = [arrayOfPositions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    
    NSMutableArray *attrStrings = [[NSMutableArray alloc] init];
    
    int currentStartPosition = 0;
    int currentWordNumber = 0;
    //search the text for words that start with b:
    for (NSString *word in arrayOfPositions)
    {
        int lengthToAdd = (int)word.length;
        //NSLog(word);
        if ([word rangeOfString:@"b:"].location != NSNotFound)
        {
            NSLog(@"string contains b:");
            
            NSString *parsedWord = [word stringByReplacingOccurrencesOfString:@"b:" withString:@""];
            
            NSRange replaceRange = [serverStringWithTags rangeOfString:word];
            if (replaceRange.location != NSNotFound)
            {
               serverStringWithTags = [serverStringWithTags stringByReplacingCharactersInRange:replaceRange withString:parsedWord];
            }
            
            NSMutableDictionary *wordInfo = [[NSMutableDictionary alloc]init];
            [wordInfo setObject:parsedWord forKey:@"word"];
            [wordInfo setObject:@"bold" forKey:@"attrType"];
            [wordInfo setObject:[NSNumber numberWithInt:currentStartPosition] forKey:@"startPosition"];
            [wordInfo setObject:[NSNumber numberWithInt:currentWordNumber] forKey:@"wordNum"];
            [attrStrings insertObject:wordInfo atIndex:attrStrings.count];
            
            lengthToAdd = (int)parsedWord.length;
            
        }
        
        if (word.length > 0)
        {
            currentWordNumber += 1;
            currentStartPosition += lengthToAdd;
        }
    }
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:serverStringWithTags];
    
    for (NSMutableDictionary *wordInfo in attrStrings)
    {
        int start = (int)[[wordInfo objectForKey:@"startPosition"] integerValue];
        NSString *end = [wordInfo objectForKey:@"word"];
        int wordNum = (int)[[wordInfo objectForKey:@"wordNum"] integerValue];
        
        [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17] range:NSMakeRange(start + wordNum, end.length)];
    }
    
    return attrString;
}

@end
