//
//  TaggingView.h
//  KidsLink
//
//  Created by Dale McIntyre on 2/19/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaggingViewDelegate
    -(void)tagViewShouldBeginEditing:(id)sender;
    -(void)tagViewDidEndEditing:(id)sender;
    -(void)tagViewPersonTagged:(NSMutableDictionary *)person;
    -(void)tagViewShowTable:(id)sender;
    -(void)tagViewHideTable:(id)sender;
@end

@interface TaggingView : UIView <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *personArray;
    
    //Text view that the user types into
    UITextView *textView;
}

@property (strong, nonatomic) NSArray *personArray;
@property (strong, nonatomic) UITextView *textView;
@property (nonatomic, assign) id<TaggingViewDelegate> delegate;
//label inside the text view with instructions to the user
@property (nonatomic, strong) UILabel *placeholderLabel;

//For MOMENTS
@property (nonatomic, strong) UILabel *momentPlaceholderLabel;
@property (nonatomic, strong) UILabel *momentTagPlaceholderLabel;



-(NSString *)getFormattedText:(NSString *)stringToFormat :(NSArray *)personsNames;
-(void)textChangedCustomEvent;
-(NSArray *)getAllTaggedIds;


@end
