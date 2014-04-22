//
//  HttpConnection.h
//  TitanIOS
//
//  Created by venkat on 4/19/14.
//  Copyright (c) 2014 Venkat Palivela. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OnSuccess)(NSDictionary *jsonResponse);
typedef void(^OnFailure)(NSError *error);


@interface RestfulConnection : NSObject

@property (nonatomic) NSString *url;
@property (nonatomic) NSString *authorizationToken;

- (id)initWithUrl:(NSString *)url andAuthorizationToken:(NSString *)token;

// Helpers
- (NSMutableURLRequest *)createRequestForEndpoint:(NSString *)endpoint;
- (void)get:(NSString *)endpoint withSuccess:(OnSuccess)onSucessBlock withFailure:(OnFailure)onFailureBlock;

@end
