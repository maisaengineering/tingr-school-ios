//
//  RemindersView.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/10/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "RemindersView.h"

@implementation RemindersView
{
  
    UILabel *emtyContentLabel;
}
@synthesize storiesDict;
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
    UIImageView *scheduleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reminder_icon.png"]];
    float yposition = (self.frame.size.height - 40)/2.0;
    [scheduleImage setFrame:CGRectMake(7, yposition, 40, 40)];
    [self addSubview:scheduleImage];

    streamTableView = [[UITableView alloc] initWithFrame:CGRectMake(48+8, 8, self.frame.size.width - 48-8-8, self.frame.size.height-16)];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.tableFooterView = [[UIView alloc] init];
    streamTableView.bounces = NO;
    [self addSubview:streamTableView];
    
    
    emtyContentLabel = [[UILabel alloc] initWithFrame:streamTableView.frame];
    emtyContentLabel.text = @"nothing to remind you for the day";
    emtyContentLabel.textColor = [UIColor lightGrayColor];
    emtyContentLabel.numberOfLines = 0;
    emtyContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14];
    if ( IDIOM == IPAD ) {
        emtyContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:17];
    }
    emtyContentLabel.hidden = YES;
    [self addSubview:emtyContentLabel];
    
    UIImageView *lineImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_icon.png"]];
    [lineImage2 setFrame:CGRectMake(0, self.frame.size.height-0.7, Devicewidth, 0.7f)];
    [self addSubview:lineImage2];
    
    
    streamTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self layoutTableView];

    
}
-(void)refreshData:(NSDictionary *)detailsDict
{
    if([[detailsDict objectForKey:@"birthdays"] count] == 0 &&
       [[detailsDict objectForKey:@"event_reminders"] count] == 0 &&
       [[detailsDict objectForKey:@"holidays"] count] == 0 )
    {
        emtyContentLabel.hidden = NO;
    }
    else
    {
        emtyContentLabel.hidden = YES;
        
        
    }
    storiesDict = detailsDict;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array;
    if(section == 0)
    {
        array = [storiesDict objectForKey:@"birthdays"];
    }
    else if(section == 1) {
        
        array = [storiesDict objectForKey:@"event_reminders"];
    }
    else if(section == 2){
        array = [storiesDict objectForKey:@"holidays"];
    }
    
    return array.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *detailsArray;
    if(indexPath.section == 0)
    {
        detailsArray = [storiesDict objectForKey:@"birthdays"];
    }
    else if(indexPath.section == 1) {
        
        detailsArray = [storiesDict objectForKey:@"event_reminders"];
    }
    else if(indexPath.section == 2){
        detailsArray = [storiesDict objectForKey:@"holidays"];
    }
    NSDictionary *detailsDict = [detailsArray objectAtIndex:indexPath.row];
    
    NSString *content = [detailsDict objectForKey:@"description"];
    
    UILabel *txtLabel = [UILabel new];
    txtLabel.numberOfLines = 0;
    txtLabel.text = content;
    txtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    if ( IDIOM == IPAD ) {
        txtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    }
    CGSize expectedLabelSize = [txtLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width, 9999)];
    float height = 0;
    if(expectedLabelSize.height > 24) //if there is a lot of text
    {
        height+=expectedLabelSize.height;
    }
    else //set a default size
    {
        height+=24;
    }
    
    return height;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *reuseIdentifier = @"RemindersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    }
    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    NSArray *detailsArray;
    if(indexPath.section == 0)
    {
        detailsArray = [storiesDict objectForKey:@"birthdays"];
    }
    else if(indexPath.section == 1) {
        
        detailsArray = [storiesDict objectForKey:@"event_reminders"];
    }
    else if(indexPath.section == 2){
        detailsArray = [storiesDict objectForKey:@"holidays"];
    }
    NSDictionary *detailsDict = [detailsArray objectAtIndex:indexPath.row];
    
    
    NSArray *eventArray = [storiesDict objectForKey:@"event_reminders"];
    NSArray *holidaysArray = [storiesDict objectForKey:@"holidays"];
    if(indexPath.row == detailsArray.count-1 )
    {
        if(indexPath.section == 2)
        {
            cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
        }
        else if(indexPath.section == 1) {
            if(holidaysArray.count == 0)
                cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
        }
        else {
            
            if(holidaysArray.count == 0 && eventArray.count == 0 )
                cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
            
        }
    }
    
    
    NSString *content = [detailsDict objectForKey:@"description"];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.numberOfLines = 0;
    nameLabel.text = content;
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    if ( IDIOM == IPAD ) {
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    }
    nameLabel.textColor = [UIColor darkGrayColor];
    CGSize expectedLabelSize = [nameLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width , 9999)];
    
    float height = 0;
    if(expectedLabelSize.height > 24) //if there is a lot of text
    {
        height =expectedLabelSize.height;
    }
    else //set a default size
    {
        height = 24;
    }
    nameLabel.frame = CGRectMake(0, 0, expectedLabelSize.width, height);
    [cell.contentView addSubview:nameLabel];
    if(indexPath.section == 2) {
        nameLabel.textColor = UIColorFromRGB(0x1B7EF9);
    }
    
    return cell;
    
}



@end
