//
//  MessagesView.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/10/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MessagesView.h"
#import "ProfilePhotoUtils.h"

@implementation MessagesView
{
    ProfilePhotoUtils *photoUtils;
    UILabel *emtyContentLabel;
}
@synthesize storiesArray;
@synthesize streamTableView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self baseInit];
    }
    return self;
}

-(void)baseInit
{
    photoUtils = [ProfilePhotoUtils alloc];
    
    UIImageView *scheduleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messages.png"]];
    float yposition = (self.frame.size.height - 40)/2.0;
    [scheduleImage setFrame:CGRectMake(7, yposition, 40, 40)];
    [self addSubview:scheduleImage];
    
    streamTableView = [[UITableView alloc] initWithFrame:CGRectMake(45+8, 8, self.frame.size.width - 45-8-8, self.frame.size.height-16)];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    emtyContentLabel.numberOfLines = 0;
    streamTableView.tableFooterView = [[UIView alloc] init];
    streamTableView.bounces = NO;
    [self addSubview:streamTableView];
    
    
    CGRect rect = streamTableView.frame;
    rect.origin.x+=5;
    
    emtyContentLabel = [[UILabel alloc] initWithFrame:rect];
    emtyContentLabel.text = @"no messages to show";
    emtyContentLabel.textColor = [UIColor lightGrayColor];
    emtyContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:17];
    if ( IDIOM == IPAD ) {
        emtyContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:17];
    }
    emtyContentLabel.hidden = YES;
    [self addSubview:emtyContentLabel];

    streamTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self layoutTableView];

    
}
-(void)refreshData:(NSArray *)detailsArray
{
    if(detailsArray.count == 0)
    {
        emtyContentLabel.hidden = NO;
    }
    else
    {
        emtyContentLabel.hidden = YES;
        
        
    }
    storiesArray = [detailsArray mutableCopy];
    [self.streamTableView reloadData];
    [self layoutTableView];

}
#pragma mark -
#pragma mark TableView

- (void)layoutTableView {
    
    [streamTableView layoutIfNeeded];
    
    CGSize contentSize = streamTableView.contentSize;
    
    CGFloat totalHeight = CGRectGetHeight(streamTableView.bounds);
    CGFloat contentHeight = contentSize.height;
    //If we have less content than our table frame then we can center
    
    BOOL contentCanBeCentered = contentHeight < totalHeight;
    CGFloat marginHeight = (totalHeight - contentHeight) / 2.0;

    
    if (contentCanBeCentered) {
        streamTableView.contentInset = UIEdgeInsetsMake(marginHeight, 0, -marginHeight, 0);
    } else {
        streamTableView.contentInset = UIEdgeInsetsZero;
    }
    

    }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return storiesArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *detailsDict = storiesArray[indexPath.row];
    NSString *text = [detailsDict objectForKey:@"text"];
    NSString *name = [detailsDict objectForKey:@"sender_name"];

    NSString *content = [NSString stringWithFormat:@"%@\n%@",name,text];
    
    UIFont *normalFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
    UIFont *redFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
    
    if ( IDIOM == IPAD ) {
        
        normalFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
        redFont = [UIFont fontWithName:@"HelveticaNeue" size:17];

    }
    NSDictionary *attributes = @{NSFontAttributeName : normalFont};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content   attributes:attributes];
    
    NSRange redTextRange = [content rangeOfString:name];
    [attributedString setAttributes:@{NSFontAttributeName:redFont}
                              range:redTextRange];
    
    
    NIAttributedLabel *textView = [NIAttributedLabel new];
    textView.numberOfLines = 0;
    textView.attributedText = attributedString;
    CGSize expectedLabelSize = [textView sizeThatFits:CGSizeMake(streamTableView.frame.size.width-35, 9999)];
    
    float height = 0;
    if(expectedLabelSize.height > 40) //if there is a lot of text
    {
        height = expectedLabelSize.height;
    }
    else //set a default size
    {
        height = 40;
    }
    return height;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"StreamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    NSDictionary *detailsDict = storiesArray[indexPath.row];
    NSString *text = [detailsDict objectForKey:@"text"];
    NSString *name = [detailsDict objectForKey:@"sender_name"];
    NSString *url = [detailsDict objectForKey:@"photograph"];
    NSString *childName = [detailsDict objectForKey:@"child_name"];
    NSString *childRelationship = [detailsDict objectForKey:@"child_relationship"];
    
    UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 30, 30)];
    [imagVw setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
    //add initials
    
    NSString *firstName = [[name substringToIndex:1]uppercaseString];
    NSArray *nameArray = [name componentsSeparatedByString:@" "];
    NSString *lName = @"";
    if(nameArray.count > 1)
    {
        lName = nameArray[1];
    }
    
    
    NSMutableString *commenterInitial = [[NSMutableString alloc] init];
    [commenterInitial appendString:firstName];
    
    
    NSMutableAttributedString *attributedTextForComment = [[NSMutableAttributedString alloc] initWithString:commenterInitial attributes:nil];
    
    NSRange range;
    if(firstName.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Bold" size:14]}
                                          range:range];
    }
    
    if(lName.length > 0)
    {
        
        NSMutableAttributedString *attributedLname = [[NSMutableAttributedString alloc] initWithString:[[lName substringToIndex:1] uppercaseString] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Light" size:14]}];
        [attributedTextForComment appendAttributedString:attributedLname];
    }
    
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    initial.attributedText = attributedTextForComment;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [imagVw addSubview:initial];
    //end add initials
    
    __weak UIImageView *weakSelf = imagVw;
    if(url != (id)[NSNull null] && url.length > 0)
    {
        // Fetch image, cache it, and add it to the tag.
        [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [weakSelf setImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(51, 51)] withRadious:0]];
             [initial removeFromSuperview];
         }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             DebugLog(@"fail");
         }];
    }
    
    [cell.contentView addSubview:imagVw];
    
    
    
    NSString *relationText = @"";
    NSString *content = [NSString stringWithFormat:@"%@\n%@",name,text];
    if(childName.length >0 && childRelationship.length >0)
    {
        relationText = [NSString stringWithFormat:@"%@'s %@",childName,childRelationship];
        content = [NSString stringWithFormat:@"%@ %@\n%@",name,relationText,text];
    }

    
    UIFont *normalFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
    UIFont *redFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16];
    
    if ( IDIOM == IPAD ) {
        
        normalFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
        redFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15];
        
    }

    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:normalFont};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content   attributes:attributes];
    
    NSRange redTextRange = [content rangeOfString:name];
    [attributedString setAttributes:@{NSFontAttributeName:normalFont}
                              range:redTextRange];

    NSRange relationTextRange = [content rangeOfString:relationText];
    [attributedString setAttributes:@{NSFontAttributeName:redFont}
                              range:relationTextRange];

    if(![[detailsDict objectForKey:@"read_message"] boolValue]) {
        
        NSRange textRange = [content rangeOfString:text];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x1B7EF9),NSFontAttributeName:normalFont} range:textRange];

        
    }
    
    
    NIAttributedLabel *textView = [NIAttributedLabel new];
    textView.numberOfLines = 0;
    textView.delegate = self;
    textView.autoDetectLinks = YES;
    textView.attributedText = attributedString;
    [cell.contentView addSubview:textView];
    
    CGSize expectedLabelSize = [textView sizeThatFits:CGSizeMake(streamTableView.frame.size.width-35, 9999)];
    
    textView.frame =  CGRectMake(35, 0, expectedLabelSize.width, expectedLabelSize.height);
    
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *detailsDict = storiesArray[indexPath.row];
    NSDictionary *dict = @{@"conversation_klid":[detailsDict objectForKey:@"conversation_klid"],
                           @"organization_id":([[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"organization_id"])?[[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"organization_id"]:@"",
                           @"kid_klid":[detailsDict objectForKey:@"kl_id"]};
    [self.delegate messageTapped:dict];
}
- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    if (result.resultType == NSTextCheckingTypeLink) {
        [[UIApplication sharedApplication] openURL:result.URL];
    }
}






@end
