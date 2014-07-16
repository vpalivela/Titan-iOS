//
//  HttpConnection.m
//  TitanIOS
//
//  Created by venkat on 4/19/14.
//  Copyright (c) 2014 Venkat Palivela. All rights reserved.
//

#import "RestfulConnection.h"

//@interface RestfulConnection ()
//
//
//@end

@implementation RestfulConnection {
    
}

- (id)initWithUrl:(NSString *)url andAuthorizationToken:(NSString *)token
{
    self = [super init];
    
    if(self) {
        self.url = url;
        self.authorizationToken = token;
    }
    
    return self;
}

- (NSMutableURLRequest *)createRequestForEndpoint:(NSString *)endpoint
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.url, endpoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:[NSString stringWithFormat:@"Basic %@", self.authorizationToken] forKey:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (void)get:(NSString *)endpoint withSuccess:(OnSuccess)onSucessBlock withFailure:(OnFailure)onFailureBlock
{
    NSMutableURLRequest *request = [self createRequestForEndpoint:endpoint];

    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            onFailureBlock(connectionError);
        } else if (data) {
            onSucessBlock(nil);
        }
    }];
}


@end
