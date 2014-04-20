//
//  HttpConnection.m
//  TitanIOS
//
//  Created by venkat on 4/19/14.
//  Copyright (c) 2014 Venkat Palivela. All rights reserved.
//

#import "RestfulConnection.h"

@interface RestfulConnection ()


@end

@implementation RestfulConnection

- (id)initWithUrl:(NSString *)url andAuthorizationToken:(NSString *)token
{
    self = [super init];
    
    if(self) {
        self.url = url;
        self.authorizationToken = token;
    }
    
    return self;
}

- (void)get:(NSString *)endpoint withSuccess:(OnSuccess)onSucessBlock withFailure:(OnFailure)onFailureBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.url, endpoint]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setValue:[NSString stringWithFormat:@"Basic %@", self.authorizationToken] forKey:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        
//    }];
}


@end
