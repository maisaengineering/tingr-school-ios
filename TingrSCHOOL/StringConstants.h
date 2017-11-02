
//APP VERSION
#define APP_VERSION     @"1.1.3"


// DEV KEYS
#define CLIENT_ID        @"aa55735c1a808ad1ec0b716296bb373182c7e95fdd343063ec2d134487b86289"
#define CLIENT_SECRET    @"6d14d914927cfb8535fab9fbc73e91c975b9fb49993c0b25476a9b0b1c41e0fc"

//API URLS

#define kBASE_URL        @"http://tingrdev-env.3vwvxmaqsp.us-east-1.elasticbeanstalk.com/"
#define BASE_URL         @"http://tingrdev-env.3vwvxmaqsp.us-east-1.elasticbeanstalk.com/api/"
#define kBaseURL         @"http://tingrdev-env.3vwvxmaqsp.us-east-1.elasticbeanstalk.com/api"

/*

// Prod Credentials
#define CLIENT_ID        @"d32036070a7bc48ed6fef9b2481cb1d820b044779d6aaed115c0755e6899ca03"
#define CLIENT_SECRET    @"745020ab7921c4dc0a567b8caed4481e69731a21edcdcfe4d0b43c29625f0570"

//API URLS
#define kBASE_URL        @"https://tingr.org.com"
#define BASE_URL         @"https://tingr.org/api/"
#define kBaseURL         @"https://tingr.org/api"
*/

#define PARSE_APPLICATION_KEY   @"5QL5BzQLkteqxx8g67MbvkeSxaOqlcptVMiCMO8I"
#define PARSE_CLIENT_KEY        @"uwIavIaJj75NhUffiQ7oQG0oDAysZvK37X5NKT8F"

#define FLURRY_KEY       @"2M98PVGP365QQBD9VQX2"


#define TimeStamp [NSString stringWithFormat:@"%i",[[NSDate date] timeIntervalSince1970] * 1000]


// Facebook Namespace
#define FACEBOOK_NAME_SPACE       @"prodmioskidslink"

//AVIARY
#define kAFAviaryAPIKey         @"e9d5541aa86c51c9"
#define kAFAviarySecret         @"ea86727d549f068d"

// NOTIFICATION STRINGS
#define POP_TO_LOGIN            @"POP_TO_LOGIN"
#define POP_TO_DOCUMENT_LIST    @"POP_TO_DOCUMENT_LIST"
#define PUSH_TO_SAVE_A_DOCUMENT @"PUSH_TO_SAVE_A_DOCUMENT"
#define FACEBOOK_CHECK          @"FACEBOOK_CHECK"
#define SET_MORE_BADGE          @"SET_MORE_BADGE"
#define SET_FRIEND_BADGE        @"SET_FRIEND_BADGE"

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define Deviceheight  [UIScreen mainScreen].bounds.size.height
#define Devicewidth  [UIScreen mainScreen].bounds.size.width
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#define MainWindow [[[UIApplication sharedApplication] delegate] window]
#define Spinner [CustomDailogueUtilis sharedInstance]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

//Alert
#define ShowAlert(title,msg,cancelButtonName) UIAlertView *alert =[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cancelButtonName otherButtonTitles:nil];\
[alert show];

#define PROJECT_NAME            @"TingrSCHOOL"

//iBeacon UUID
#define BEACON_UUID @"DDDDDDDD-BBBB-DDDD-BBBB-DBDBDBDBDBDB"
#define BEACON_IDENTIFIER @"org.tingr.teacher.prod"



//SPECIFIC WEB PAGES
#define REQUEST_INVITATION      @"http://mykidslink.com/in-app/iPhone/getInvitation201410.html"
#define SIGNUP                  @"http://www.mykidslink.com/in-app/iPhone/getInvitation.html"
#define REDEEM_INVITATION       @"https://me.mykidslink.com/m/get-invited"
#define ORGANIZATIONS           @"http://www.mykidslink.com/in-app/iPhone/organizations.html"
#define SUPPORT                 @"http://www.mykidslink.com/in-app/iPhone/support.html"
#define ADD_CHILD_LEARN_MORE    @"http://www.mykidslink.com/in-app/iPhone/addChildLearnMore.html"
#define CHILD_EDIT_LEARN_MORE   @"http://www.mykidslink.com/in-app/iPhone/profileDetailsLearnMore.html"

#define CTTimeStart() NSDate * __date = [NSDate date]
#define CTTimeEnd(MSG) DebugLog(MSG " %g",[__date timeIntervalSinceNow]*-1)

//VALIDATION MESSAGES AND MISC MESSAGES
#define NO_INTERNET_CONNECTION  @"No internet connection. Try again after connecting to internet"
#define FAILED_LOGIN            @"Username and Password didn't match."
#define PASSWORD_LENGTH_INVALID @"Password must be at least 6 characters."
#define EMAIL_INVALID           @"Please provide a valid email address."
#define EMAIL_PASS_REQUIRED     @"Please enter your email and password."
#define ALL_FIELDS_REQUIRED     @"All fields are required"
#define FORGOT_PASS_SUCCESS_MESSAGE @"You will receive an email with instructions about how to reset your password in a few minutes."
#define ENTER_PHONE_NUMBER      @"Please enter phone number"
#define NO_CAMERA               @"This device doesn't have a camera."
#define NO_PHOTO_LIBRARIES      @"This device doesn't support photo libraries."
#define DOCUMENT_OWNER          @"Please select who this document belongs to"
#define SELECT_DOC_TYPE         @"Please select the document type"
#define ADD_DOC_TYPE            @"Add document type"
#define ENTER_DOC_DETAILS       @"Enter the details about this document"

//CONTROLLER TEXT
#define LOADING                 @"Loading..."

//FACEBOOK
#define TITLE_URL               @"http://www.mykidslink.com"

//INSTAGRAM
#define INSTAGRAM_ALERT_TITLE         @"Oops!"
#define INSTAGRAM_ALERT_BODY_SHARE    @"You can't share to Instagram without a photo. Make sure to select one above."
#define INSTAGRAM_ALERT_OK            @"OK"
#define INSTAGRAM_ALERT_BODY_INSTALL  @"You don't have Instagram installed. Download Instagram from the App Store to share from KidsLink."
#define SHOW_INSTAGRAM_MESSAGE        @"SHOW_INSTAGRAM_MESSAGE"
#define HIDE_INSTAGRAM_MESSAGE        @"HIDE_INSTAGRAM_MESSAGE"
// For Streams
#define INSTAGRAM_ALERT_TITLE_SHARE_NOPHOTO_IN_STREAMS   @"Oops!"
#define INSTAGRAM_ALERT_BODY_SHARE_NOPHOTO_IN_STREAMS    @"You can't share to Instagram without a photo."

#define FACEBOOK_ALERT_TITLE_FOR_SAYSOMETHING_FIRST_POST @"Oops!"
#define FACEBOOK_ALERT_BODY_FOR_SAYSOMETHING_FIRST_POST  @"Say Something posts can't be shared to Facebook"
#define FACEBOOK_ALERT_OK                                @"OK"

#define INSTAGRAM_ALERT_TITLE_FOR_SAYSOMETHING_FIRST_POST @"Oops!"
#define INSTAGRAM_ALERT_BODY_FOR_SAYSOMETHING_FIRST_POST  @"Say Something posts can't be shared to Instagram"



