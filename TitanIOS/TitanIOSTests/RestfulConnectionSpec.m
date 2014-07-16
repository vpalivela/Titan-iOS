//
//  HttpConnectionSpec.m
//  TitanIOS
//
//  Created by venkat on 4/19/14.
//  Copyright (c) 2014 Venkat Palivela. All rights reserved.
//
#import "Kiwi.h"
#import "RestfulConnection.h"


SPEC_BEGIN(RestfulConnectionSpec)

__block NSString *baseUrl;
__block NSString *token;
__block RestfulConnection *connection;


beforeEach(^{
    baseUrl    = @"http://sometesturl.com";
    token      = @"someToken";
    connection = [[RestfulConnection alloc] initWithUrl:baseUrl andAuthorizationToken:token];
});

describe(@"construction", ^{
    it(@"should create with url and authorization token", ^{
        [[connection.url should] equal:baseUrl];
        [[connection.authorizationToken should] equal:token];
    });
});

describe(@"createRequestForEndpoint", ^{
    __block NSMutableURLRequest *mockRequest = [NSMutableURLRequest nullMock];
    
    it(@"should create a http get request to endpoint with auth token", ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/endpoint", baseUrl]];
        [[NSMutableURLRequest should] receive:@selector(requestWithURL:) andReturn:mockRequest withArguments:url];
        [[mockRequest should] receive:@selector(setValue:forKey:) andReturn:nil withArguments:@"Basic someToken", @"Authorization"];
        [[mockRequest should] receive:@selector(setHTTPMethod:) withArguments:@"GET"];
        
        [connection createRequestForEndpoint:@"/endpoint"];
    });
    
});

describe(@"GET", ^{
    __block NSMutableURLRequest *mockRequest = [NSMutableURLRequest nullMock];

    __block BOOL isSuccessfulCalled = NO;
    __block BOOL isErrorCalled      = NO;
    
    beforeEach(^{
        isSuccessfulCalled = NO;
        isErrorCalled      = NO;
        [[connection should] receive:@selector(createRequestForEndpoint:) andReturn:mockRequest];
    });
    
    it(@"should only return on success block when the request was successful", ^{
        
        [NSURLConnection stub:@selector(sendAsynchronousRequest:queue:completionHandler:) withBlock:^id(NSArray *params) {
            void (^completionHandler)(NSURLResponse *response, NSData *data, NSError *connectionError) = params[2];
            completionHandler(nil, [NSData new], nil);
            return nil;
        }];
        
        [connection get:@"/status" withSuccess:^(NSDictionary *jsonResponse) {
            isSuccessfulCalled = YES;
        } withFailure:^(NSError *error) {
            isErrorCalled = YES;
        }];
        
        [[theValue(isSuccessfulCalled) should] beYes];
        [[theValue(isErrorCalled) should] beNo];
    });
    
    it(@"should only return on error block when the request was errored out", ^{
        [NSURLConnection stub:@selector(sendAsynchronousRequest:queue:completionHandler:) withBlock:^id(NSArray *params) {
            void (^completionHandler)(NSURLResponse *response, NSData *data, NSError *connectionError) = params[2];
            completionHandler(nil, nil, [NSError new]);
            return nil;
        }];
        
        [connection get:@"/status" withSuccess:^(NSDictionary *jsonResponse) {
            isSuccessfulCalled = YES;
        } withFailure:^(NSError *error) {
            isErrorCalled = YES;
        }];
        
        [[theValue(isSuccessfulCalled) should] beNo];
        [[theValue(isErrorCalled) should] beYes];
    });
});

SPEC_END