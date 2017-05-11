//
//  CommentsUtils.m
//  KidsLink
//
//  Created by Dale McIntyre on 12/26/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "CommentsUtils.h"

@implementation CommentsUtils


+(NSMutableDictionary*)getCommentDetails:(NSMutableDictionary*)currentStory comment_details:(NSMutableDictionary*)comment_details
{
    int comments_shown = 0;
    NSString *showMoreButton = @"false";
    
    NSArray *commentsArray = [currentStory objectForKey:@"comments"];
    int comments_count = (int)commentsArray.count;
    
    if (!comment_details)
    {
        comment_details = [[NSMutableDictionary alloc]init];
        [comment_details setValue:@"false" forKey:@"show_more_clicked"];
        
        if (comments_count < 5)
        {
            comments_shown = comments_count;
            //do not show button
        }
        else if (comments_count > 4)
        {
            comments_shown = 4;
            showMoreButton = @"true";
        }
    }
    else
    {
        comments_shown = [[comment_details objectForKey:@"total_toshow"] intValue];
        
        if ([[comment_details objectForKey:@"show_more_clicked"] isEqualToString:@"true"])
        {
            //reset it
            [comment_details setValue:@"false" forKey:@"show_more_clicked"];
            
            NSArray *commentsArray = [currentStory objectForKey:@"comments"];
            int comments_count = (int)commentsArray.count;
            //set the number of comments to show here by algorythm
            if (comments_count < 5)
            {
                comments_shown = comments_count;
                //do not show button
            }
            else if (comments_count > 4)
            {
                //commments array needs to be limited to commentcountnum total
                if (comments_shown < 4)
                {
                    comments_shown = 4;
                    showMoreButton = @"true";
                }
                else if (comments_shown == 4)
                {
                    //set up to 10
                    if (comments_count < 10)
                    {
                        comments_shown = comments_count;
                    }
                    else
                    {
                        comments_shown = 10;
                        showMoreButton = @"true";
                    }
                }
                else if (comments_shown >= 10)
                {
                    if (comments_count < (comments_shown + 10))
                    {
                        comments_shown = comments_count;
                    }
                    else
                    {
                        comments_shown = comments_shown + 10;
                        showMoreButton = @"true";
                    }
                }
                
            }
        }
        else
        {
            NSArray *commentsArray = [currentStory objectForKey:@"comments"];
            int comments_count = (int)commentsArray.count;

            
            NSString *comment_added = [currentStory objectForKey:@"comment_added"];
            
            if (comment_added)
            {
                if ([comment_added isEqualToString:@"true"])
                {
                    //comments_shown += 1;
                }
                
                [currentStory setValue:@"false" forKey:@"comment_added"];
            }
             if( [[comment_details objectForKey:@"totalCount"] intValue] != comments_count)
            {
                if(![[comment_details objectForKey:@"showMoreButton"] isEqualToString:@"true"])
                {
                    comments_shown = comments_count;
                }
            }
            //reset the comment added tag;
            
            
            if (comments_count > comments_shown)
            {
                showMoreButton = @"true";
            }
        }
        
    }
    
    [comment_details setValue:[@(comments_shown) stringValue] forKey:@"total_toshow"];
    [comment_details setValue:showMoreButton forKey:@"showMoreButton"];
    [comment_details setObject:[NSNumber numberWithInt:(int)commentsArray.count] forKey:@"totalCount"];
    return comment_details;
}

@end
