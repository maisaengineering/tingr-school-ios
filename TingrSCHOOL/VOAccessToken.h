
#import <Foundation/Foundation.h>

@interface AccessToken : NSObject
{
    NSString* access_token;
	NSString* token_type;
	NSString* expires_in;
    NSString* scope;
}

@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *token_type;
@property (strong, nonatomic) NSString *expires_in;
@property (strong, nonatomic) NSString *scope;

@end
