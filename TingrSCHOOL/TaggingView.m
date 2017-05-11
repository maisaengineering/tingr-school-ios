//
//  TaggingView.m
//  KidsLink
//
//  Created by Dale McIntyre on 2/19/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import "TaggingView.h"
#import "TaggingUtils.h"

//This view contains the nceessary items to have a drop down below the view when an @ symbol is typed so that you can tag a name
//@ plus string then space will attempt to find a name
//@ plus click on table name will set the name (in blue) - keep the @

@implementation TaggingView
{
    //This lets us know whether to show the user table or not
    BOOL isAutoTagged;
    
    //Finds the @ symbol to start searching
    NSRange tagPersonRane;
    
    // This table is to show the matched persons
    UITableView *taggableMembersTableView;
    
    // This array contains only matched profiles data.
    NSMutableArray *matchedPersons;
    
    // This is used for store the tagged person's kl-ids
    NSMutableArray *tagged_Persons_KL_IDS;
    
    //tweaks the keyboard height
    int _currentKeyboardHeight;
    
    //accessory bar for the keyboard that holds the done button
    UIView *inputView;
}

//list of names to be put into the drop down table
@synthesize personArray;
@synthesize delegate;
@synthesize textView;
@synthesize placeholderLabel;
@synthesize momentPlaceholderLabel;
@synthesize momentTagPlaceholderLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self baseInit];
    }
    return self;
}

-(void)baseInit
{
    self.clipsToBounds = FALSE;
    
    tagged_Persons_KL_IDS = [[NSMutableArray alloc] init];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
    textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
    [textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [textView setTextColor:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1]];
    [textView setBackgroundColor:[UIColor whiteColor]];
    textView.autocorrectionType = UITextAutocorrectionTypeYes;
    
    [textView setDelegate:self];
    [self addSubview:textView];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 3.0, textView.frame.size.width -5, 42)];
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [textView addSubview:placeholderLabel];
    
    momentPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, -1, textView.frame.size.width - 5.0, 15)];
    //[placeholderLabel setText:placeholder];
    [momentPlaceholderLabel setBackgroundColor:[UIColor clearColor]];
    [momentPlaceholderLabel setNumberOfLines:0];
    [momentPlaceholderLabel setTextAlignment:NSTextAlignmentLeft];
    [momentPlaceholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    [momentPlaceholderLabel setTextColor:[UIColor lightGrayColor]];
    [self addSubview:momentPlaceholderLabel];
    
    momentTagPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -0.5, textView.frame.size.width-2 , 15)];
    //[placeholderLabel setText:placeholder];
    [momentTagPlaceholderLabel setBackgroundColor:[UIColor clearColor]];
    [momentTagPlaceholderLabel setNumberOfLines:0];
    [momentTagPlaceholderLabel setTextAlignment:NSTextAlignmentRight];
    [momentTagPlaceholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11]];
    [momentTagPlaceholderLabel setTextColor:[UIColor lightGrayColor]];
    [self addSubview:momentTagPlaceholderLabel];
    
    // taggableMembersTableView
    taggableMembersTableView = [[UITableView alloc]init];
    taggableMembersTableView.layer.borderColor = [UIColor grayColor].CGColor;
    [taggableMembersTableView setFrame:CGRectMake(0,115,self.frame.size.width, 400)];
    taggableMembersTableView.delegate = self;
    taggableMembersTableView.dataSource = self;
    [self addSubview:taggableMembersTableView];
    taggableMembersTableView.hidden = YES;
    
    
    if ( IDIOM == IPAD ) {

        
        [textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
        [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [momentPlaceholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [momentTagPlaceholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        
    }
    matchedPersons = [[NSMutableArray alloc]init];
    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(Devicewidth-70, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:donebtn];
    
}

#pragma mark - Keyboard Delegates
- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _currentKeyboardHeight = kbSize.height;
}

#pragma mark - Textview Delegates

//THIS method gets called any time text field's contents are about to change (entering, deleting, cutting or pasting text)
- (BOOL)textView:(UITextView *)textVie shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //create a copy of the attributed string
    NSMutableAttributedString *attributedString = [textVie.attributedText mutableCopy];
    
    [attributedString beginEditing];
    
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange attrRange, BOOL *stop) {
         
         if(attrRange.location < range.location && range.location <= attrRange.location+attrRange.length-1)
         {
             NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
             
             UIFont *currentFont = [mutableAttributes objectForKey:@"NSFont"];
             
             if ([[currentFont fontName] isEqualToString:@"HelveticaNeue-Medium"])
             {
                 NSRange selectedRange = textView.selectedRange;
                 [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]} range:attrRange];
                 textView.attributedText = attributedString;
                 textView.selectedRange = selectedRange;
             }
         }
     }];
    
    [attributedString endEditing];
    
    textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    [textView setInputAccessoryView:inputView];
    [momentPlaceholderLabel removeFromSuperview];
    [momentTagPlaceholderLabel removeFromSuperview];
    [placeholderLabel removeFromSuperview];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    
    [self.delegate tagViewShouldBeginEditing :self];
    [textView setInputAccessoryView:inputView];
    [momentPlaceholderLabel removeFromSuperview];
    [momentTagPlaceholderLabel removeFromSuperview];
    [placeholderLabel removeFromSuperview];
    
    return YES;
    
}
- (void)textViewDidEndEditing:(UITextView *)txtView
{
    if (![textView hasText])
    {
        [textView addSubview:placeholderLabel];
        [self addSubview:momentTagPlaceholderLabel];
        [self addSubview:momentPlaceholderLabel];
    }
    [self.delegate tagViewDidEndEditing :self];
}
- (void)textViewDidChange:(UITextView *)textView1
{
    if(![textView hasText])
    {
        [self hideTable];
        [textView addSubview:placeholderLabel];
        [self addSubview:momentTagPlaceholderLabel];
        [self addSubview:momentPlaceholderLabel];
    }
    else if ([[textView subviews] containsObject:placeholderLabel])
    {
        [momentPlaceholderLabel removeFromSuperview];
        [momentTagPlaceholderLabel removeFromSuperview];
        [placeholderLabel removeFromSuperview];
        
    }
    textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
    
    [self searchTableView:[textView.text substringWithRange:NSMakeRange(0, textView.selectedRange.location)]];
}

-(void)textChangedCustomEvent
{
    [placeholderLabel removeFromSuperview];
    [momentPlaceholderLabel removeFromSuperview];
    [momentTagPlaceholderLabel removeFromSuperview];

}

- (void) searchTableView:(NSString *)textString
{
    tagged_Persons_KL_IDS = [[TaggingUtils getAllTaggedIds:textView.attributedText :personArray] mutableCopy];
    
    //NOTE: the textString in just the text from the curson point backwards to the beginning of the string
    
    // finding the @ symbol range - hits the first occurrence - starting at the end of a string
    tagPersonRane = [textString rangeOfString:@"@" options:NSBackwardsSearch];
    
    //no @ found
    if (tagPersonRane.location == NSNotFound)
    {
        [self hideTable];
    }
    else //found us an @ symbol
    {
#pragma mark - searchString contains only text after @
        NSString *searchString = @"";
        NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
        
        if(textView.selectedRange.location - tagPersonRane.location > 1)
        {
            searchString = [textView.text substringWithRange:NSMakeRange(tagPersonRane.location+1, textView.selectedRange.location-tagPersonRane.location-1)];
        }
        
        //If searchstring is empty (space) after the @ then do not bring up the table
        if (searchString.length>0 && [searchString rangeOfCharacterFromSet:s].location != NSNotFound)
        {
            
            [matchedPersons removeAllObjects];
            
            NSString *searchText = searchString;
            
            for (int i=0;i<personArray.count;i++ )
            {
                NSString *sTemp = [NSString stringWithFormat:@"%@",[[personArray objectAtIndex:i] valueForKey:@"name"]];
                
                NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
                
                if (titleResultsRange.length > 0 && ![tagged_Persons_KL_IDS containsObject:[[personArray objectAtIndex:i] valueForKey:@"kl_id"]])
                {
                    // The matched persons array contains the same friend or not
                    //DebugLog(@"%@",[personArray objectAtIndex:i]);
                    if (![matchedPersons containsObject:[personArray objectAtIndex:i]])
                    {
                        [matchedPersons addObject:[personArray objectAtIndex:i]];
                    }
                    
                }

                // last character of the user entered text with @
                NSString *lastCharacter = [NSString stringWithFormat:@"%@",[searchString substringFromIndex:[searchString length]-1]];
                
                // To check the last character has a special character or not
                NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789!@#$%^&*()_{}|:<>?~"] invertedSet];
                
                if ([lastCharacter rangeOfCharacterFromSet:set].location != NSNotFound)
                {
                    //DebugLog(@"searchString contain text after @:**%@**",searchString);
                    //DebugLog(@"searchString contain last lette @:**%@**",[searchString substringFromIndex:[searchString length]-1]);
                    
                    if ([lastCharacter length] > 0)
                    {
                        //DebugLog(@"Before removing last char:**%@**",searchString);
                        //DebugLog(@"After removing last  char:**%@**",searchString);
                        
                        // After removed the last special character get the string for matching person
                        searchString = [searchString substringToIndex:[searchString length] - 1];
                        if(searchString.length == 0 )
                        {
                            [self hideTable];
                            break;
                        }
                        
                        // Apply the filter search (WHEN A Space comes at the end)
                        for (int j=0;j<personArray.count;j++ )
                        {
                            //this is just the name of the person in the array item
                            //IMP - this field must be in all datasets
                            NSString *eachperson = [NSString stringWithFormat:@"%@",[[personArray objectAtIndex:j] valueForKey:@"name"]];
                            
                            //if the search string matches the person string AND not already in the matching names list
                            if ([eachperson.lowercaseString isEqualToString:searchString.lowercaseString] && (![tagged_Persons_KL_IDS containsObject:[[personArray objectAtIndex:j] valueForKey:@"kl_id"]]))
                            {
                                DebugLog(@"matching");
                                
                                //NSString *selectedPerson = @"";
                                //selectedPerson = [NSString stringWithFormat:@"%@%@",[[personArray objectAtIndex:j] valueForKey:@"short_name"],lastCharacter];
                                
                                //Changes the color and font of the name
                                NSDictionary *attribs = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(72/255.f) green:(187/255.f) blue:(234/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]};
                                //just the name in search string
                                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:searchString attributes:attribs];
                                NSRange range;
                                range.length = tagPersonRane.location;
                                range.location = 0;
                                
                                //The range for this one ends where the name in the string begins
                                //ie.I am looking for testbo has a range of 0 to 17
                                NSMutableAttributedString *attributedText1 = [[textView.attributedText attributedSubstringFromRange:range] mutableCopy];
                                //appends the name at the 17th char in blue, essentially just updating the name to a blue name
                                [attributedText1 appendAttributedString:attributedText];
                                
                                if(textView.text.length > textView.selectedRange.location)
                                {
                                    range = textView.selectedRange;
                                    range.length = textView.text.length - range.location;
                                    [attributedText1 appendAttributedString:[textView.attributedText attributedSubstringFromRange:range]];
                                }
                                
                                //put in space for when they use space when tagging
                                NSMutableAttributedString *attributedTextSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:nil];
                                [attributedText1 appendAttributedString: attributedTextSpace];
                                
                                textView.attributedText = attributedText1;
  
                                [self hideTable];
                                
                                if (![tagged_Persons_KL_IDS containsObject:[[personArray objectAtIndex:j] valueForKey:@"kl_id"]])
                                {
                                    //[tagged_Persons_KL_IDS addObject:[[personArray objectAtIndex:j] objectForKey:@"kl_id"]];
                                    [self.delegate tagViewPersonTagged :[personArray objectAtIndex:j]];
                                    //[matchedPersons addObject:[personArray objectAtIndex:j]];
                                }
                                
                                DebugLog(@"matchedPersons:%@",matchedPersons);
                                
                                isAutoTagged = YES;
                                
                            }
                            else
                            {
                                //DebugLog(@"not matching");
                            }
                        }
                        
                    }
                    else
                    {
                        //no characters to delete... attempting to do so will result in a crash
                    }
                }
                else
                {
                    //DebugLog(@"last character is not a special char in :**%@**",searchString);
                    // DebugLog(@"last character is not a special char in");
                   [self showTable];
                }
                
            }
            
            if (matchedPersons.count > 0)
            {
                if (isAutoTagged)
                {
                    isAutoTagged = NO;
                    [self hideTable];
                }
                else
                {
                    [self showTable];
                    
                    // To show the recommended list below the cursor position
                    CGPoint cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
                    
                    CGPoint p = [self convertPoint:cursorPosition fromView:textView];
                    //UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                    
                    if(p.y+30 >= textView.frame.origin.y+textView.frame.size.height)
                    {
                        int yPosition = textView.frame.origin.y+textView.frame.size.height;
                        int height = 175; //window.frame.size.height-yPosition-_currentKeyboardHeight+20;
                        [taggableMembersTableView setFrame:CGRectMake(taggableMembersTableView.frame.origin.x, yPosition, taggableMembersTableView.frame.size.width, height)];
                        
                    }
                    else
                    {
                        int yPosition = p.y+30;
                        int height = 175; //window.frame.size.height-yPosition-_currentKeyboardHeight+20;
                        [taggableMembersTableView setFrame:CGRectMake(taggableMembersTableView.frame.origin.x, yPosition, taggableMembersTableView.frame.size.width, height)];
                        
                    }
                    
                    //this is to make sure it is on top of all the other subviews
                    [self addSubview:taggableMembersTableView];

                    [taggableMembersTableView reloadData];
                }
            }
            else
            {
                [self hideTable];
            }
            
        }
        else
        {
            [self hideTable];
        }
    }
}
#pragma mark - UITableView Datasource Methods
#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return matchedPersons.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //standard code to initiate the cell
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Roman" size:18];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[matchedPersons objectAtIndex:indexPath.row] valueForKey:@"name"]];
    cell.textLabel.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    return cell;
}


//This will set the tag from clicking on the list of taggable names
#pragma mark - UITableView Delgate Methods
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedPerson = @"";
    selectedPerson = [NSString stringWithFormat:@"%@",[[matchedPersons objectAtIndex:indexPath.row] valueForKey:@"name"]];
    
    NSDictionary *attribs = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(72/255.f) green:(187/255.f) blue:(234/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:selectedPerson attributes:attribs];
    NSRange range;
    range.length = tagPersonRane.location;
    range.location = 0;
    
    NSMutableAttributedString *attributedText1 = [[textView.attributedText attributedSubstringFromRange:range] mutableCopy];
    [attributedText1 appendAttributedString:attributedText];
    
    if(textView.text.length > textView.selectedRange.location)
    {
        range = textView.selectedRange;
        range.length = textView.text.length - range.location;
        [attributedText1 appendAttributedString:[textView.attributedText attributedSubstringFromRange:range]];
    }
    
    textView.delegate = nil;
    textView.attributedText = attributedText1;
    textView.delegate = self;
    
    textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
    
    //[tagged_Persons_KL_IDS addObject:[[matchedPersons objectAtIndex:indexPath.row] objectForKey:@"kl_id"]];
    [self.delegate tagViewPersonTagged :[matchedPersons objectAtIndex:indexPath.row]];
    
    [self hideTable];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [matchedPersons removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
    
}

-(void)doneClick:(id)sender
{
    [textView resignFirstResponder];
    //[self hideTable];
}

-(NSString *)getFormattedText:(NSString *)stringToFormat :(NSArray *)personsNames
{
    //this combines the names with the kl_id
    
    
    return stringToFormat;
}

-(NSArray *)getAllTaggedIds
{
    return [TaggingUtils getAllTaggedIds:textView.attributedText :personArray];
}

-(void)showTable
{
    taggableMembersTableView.hidden = NO;
    [self.delegate tagViewShowTable :self];
}

-(void)hideTable
{
    taggableMembersTableView.hidden = YES;
    [self.delegate tagViewHideTable :self];
}


@end
