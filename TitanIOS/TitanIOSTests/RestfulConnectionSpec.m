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

describe(@"GET", ^{
    __block NSMutableURLRequest *mockRequest = [NSMutableURLRequest mock];
    
    beforeEach(^{
        [[NSMutableURLRequest should] receive:@selector(alloc) andReturn:mockRequest];
    });
    
    it(@"should create a http getrequest to endpoint with auth token", ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/status", baseUrl]];
        [[mockRequest should] receive:@selector(initWithURL:) andReturn:mockRequest withArguments:url];
        [[mockRequest should] receive:@selector(setValue:forKey:) andReturn:nil withArguments:@"Basic someToken", @"Authorization"];
        [[mockRequest should] receive:@selector(setHTTPMethod:) withArguments:@"GET"];
        [connection get:@"/status" withSuccess:^(NSDictionary *jsonResponse) {} withFailure:^(NSError *error) {}];
    });

    
    xit(@"should send a request asynchronously", ^{
        [[mockRequest should] receive:@selector(initWithURL:) andReturn:mockRequest];
        
//        [[NSURLConnection should] receive:@selector(sendAsynchronousRequest:queue:completionHandler:) withArguments:any(), any(), any()];
        [connection get:@"/status" withSuccess:^(NSDictionary *jsonResponse) {} withFailure:^(NSError *error) {}];
    });
    
    
    xit(@"should only return on success block when the request was successful", ^{
        
        __block BOOL isSuccessfulCalled = NO;
        __block BOOL isErrorCalled      = NO;
        
        NSURLConnection *mockConnection = [NSURLConnection nullMock];
        
        [[NSURLConnection should] receive:@selector(alloc) andReturn:mockConnection];
        [[NSURLConnection should] receive:@selector(initWithRequest:delegate:) andReturn:mockConnection];
        

        [connection get:@"/status" withSuccess:^(NSDictionary *jsonResponse) {
            isSuccessfulCalled = YES;
        } withFailure:^(NSError *error) {
            isErrorCalled = YES;
        }];
        
//        [[theValue(isSuccessfulCalled) shouldEventually] beYes];
//        [[theValue(isErrorCalled) shouldEventually] beNo];
        
    });
});

SPEC_END