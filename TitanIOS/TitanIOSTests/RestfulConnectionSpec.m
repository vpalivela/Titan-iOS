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

__block NSString *baseUrl             = @"http://sometesturl.com";
__block NSString *token               = @"someToken";
__block RestfulConnection *connection = [[RestfulConnection alloc] initWithUrl:baseUrl andAuthorizationToken:token];

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
        
        [[theValue(isSuccessfulCalled) shouldEventually] beYes];
        [[theValue(isErrorCalled) shouldEventually] beNo];
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
        
        [[theValue(isSuccessfulCalled) shouldEventually] beNo];
        [[theValue(isErrorCalled) shouldEventually] beYes];
    });
});

SPEC_END