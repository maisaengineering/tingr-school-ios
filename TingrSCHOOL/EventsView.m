//
//  EventsView.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/10/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "EventsView.h"
#import "ProfileDateUtils.h"
@implementation EventsView
{
    UILabel *emtyContentLabel;
    ProfileDateUtils *dateUtils;
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
    UIImageView *scheduleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"schedule_icon.png"]];
    float yposition = (self.frame.size.height - 40)/2.0;
    [scheduleImage setFrame:CGRectMake(8, yposition, 40, 40)];
    [self addSubview:scheduleImage];

    dateUtils  = [ProfileDateUtils alloc];
    
    storiesArray = [[NSMutableArray alloc] init];
    streamTableView = [[UITableView alloc] initWithFrame:CGRectMake(48+8, 10, self.frame.size.width - 48-8-8, self.frame.size.height-20)];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.tableFooterView = [[UIView alloc] init];
    streamTableView.bounces = NO;
    [self addSubview:streamTableView];
    
    
    emtyContentLabel = [[UILabel alloc] initWithFrame:streamTableView.frame];
    emtyContentLabel.text = @"you school has no schedule for you today";
    emtyContentLabel.numberOfLines = 0;
    emtyContentLabel.textColor = [UIColor lightGrayColor];
    emtyContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14];
    if ( IDIOM == IPAD ) {
        emtyContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:17];
    }
    emtyContentLabel.hidden = YES;
    [self addSubview:emtyContentLabel];
    
    UIImageView *lineImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_icon.png"]];
    [lineImage2 setFrame:CGRectMake(0, self.frame.size.height-0.5, Devicewidth, 0.5f)];
    [self addSubview:lineImage2];
    
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
 
    CGSize contentSize = streamTableView.contentSize;
    
    CGFloat totalHeight = CGRectGetHeight(streamTableView.bounds);
    CGFloat contentHeight = contentSize.height;
    //If we have less content than our table frame then we can center
    BOOL contentCanBeCentered = contentHeight < totalHeight;
    if (contentCanBeCentered) {
        streamTableView.contentInset = UIEdgeInsetsMake(ceil(totalHeight/2.f - contentHeight/2.f), 0, 0, 0);
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
    NSDictionary *detailsDict = [storiesArray objectAtIndex:indexPath.row];
    
    NSString *content = [detailsDict objectForKey:@"name"];
    
    UILabel *txtLabel = [UILabel new];
    txtLabel.numberOfLines = 0;
    txtLabel.text = content;
    txtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize expectedLabelSize;

    
    
    NSDate *startdate = [dateUtils dateFromScheduleString:[detailsDict objectForKey:@"start_time"]];
    NSDate *enddate = [dateUtils dateFromScheduleString:[detailsDict objectForKey:@"end_time"]];
    
    
    if(startdate == nil && enddate == nil)
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSX"];
        startdate = [dateFormatter dateFromString:[detailsDict objectForKey:@"start_time"]];
        enddate = [dateFormatter dateFromString:[detailsDict objectForKey:@"end_time"]];
    }
    
    

    
    if([self date:[NSDate date] isBetweenDate:startdate andDate:enddate])
    {
        txtLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        expectedLabelSize = [txtLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 118, 9999)];
    }
    else
    {
        txtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        expectedLabelSize = [txtLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 118, 9999)];

    }

    
    if ( IDIOM == IPAD ) {
        
        if([self date:[NSDate date] isBetweenDate:startdate andDate:enddate])
        {
            txtLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
            expectedLabelSize = [txtLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 118, 9999)];
        }
        else {
            txtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
            expectedLabelSize = [txtLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 170, 9999)];

        }
        

    }
    
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
  
        
        NSString *reuseIdentifier = @"VersionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:reuseIdentifier];
        }
    for(UIView *view in [cell.contentView subviews])
            [view removeFromSuperview];

        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    
    NSDictionary *detailsDict = [storiesArray objectAtIndex:indexPath.row];

    
    NSDate *startdate = [dateUtils dateFromScheduleString:[detailsDict objectForKey:@"start_time"]];
    NSDate *enddate = [dateUtils dateFromScheduleString:[detailsDict objectForKey:@"end_time"]];

    if(startdate == nil && enddate == nil)
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSX"];
        startdate = [dateFormatter dateFromString:[detailsDict objectForKey:@"start_time"]];
        enddate = [dateFormatter dateFromString:[detailsDict objectForKey:@"end_time"]];
    }

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mma"];
    NSString *startTime = [dateFormatter stringFromDate:startdate];
    NSString *endtime = [dateFormatter stringFromDate:enddate];
    NSString *strTime = [NSString stringWithFormat:@"%@-%@",[startTime lowercaseString],[endtime lowercaseString]];

    
        if(indexPath.row == storiesArray.count-1)
            cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
    
    
        NSString *content = [detailsDict objectForKey:@"name"];

        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.numberOfLines = 0;
        nameLabel.text = content;
    
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];


        nameLabel.textColor = [UIColor darkGrayColor];
    CGSize expectedLabelSize;
    
    
    if([self date:[NSDate date] isBetweenDate:startdate andDate:enddate])
    {
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        
        expectedLabelSize = [nameLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 118, 9999)];
        nameLabel.textColor = [UIColor blackColor];
    }
    else {
        
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        expectedLabelSize = [nameLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 118, 9999)];
    }

    
    if ( IDIOM == IPAD ) {
        
        if([self date:[NSDate date] isBetweenDate:startdate andDate:enddate])
        {
            nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
            
            expectedLabelSize = [nameLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 170, 9999)];
            nameLabel.textColor = [UIColor blackColor];
        }
        else {
            
            nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
            expectedLabelSize = [nameLabel sizeThatFits:CGSizeMake(streamTableView.frame.size.width - 170, 9999)];
        }
        
    }
    
        float height = 0;
        if(expectedLabelSize.height > 24) //if there is a lot of text
        {
            height =expectedLabelSize.height;
        }
        else //set a default size
        {
            height = 24;
        }
    if ( IDIOM == IPAD ) {
        nameLabel.frame = CGRectMake(170, 0, expectedLabelSize.width, height);
        
    }
    else
        nameLabel.frame = CGRectMake(118, 0, expectedLabelSize.width, height);

    

        [cell.contentView addSubview:nameLabel];
    
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 118, height)];
        [timeLabel setText:strTime];
    [timeLabel setTextColor:[UIColor darkGrayColor]];

    if([self date:[NSDate date] isBetweenDate:startdate andDate:enddate])
    {
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        timeLabel.textColor = [UIColor blackColor];
    }
    else {
        
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    }
    

    
    if ( IDIOM == IPAD ) {
        
        if([self date:[NSDate date] isBetweenDate:startdate andDate:enddate])
        {
            timeLabel.frame = CGRectMake(0, 0, 170, height);
            timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
            timeLabel.textColor = [UIColor blackColor];
        }
        else {
        
        timeLabel.frame = CGRectMake(0, 0, 170, height);
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        }
    }

        [cell.contentView addSubview:timeLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
        
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

@end
