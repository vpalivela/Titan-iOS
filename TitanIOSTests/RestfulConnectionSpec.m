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

describe(@"RestfulConnection", ^{
    __block NSString *baseUrl;
    __block NSString *token;
    __block RestfulConnection *connection;
    __block NSMutableURLRequest *mockRequest;
    
    beforeEach(^{
        baseUrl    = @"http://sometesturl.com";
        token      = @"someToken";
        connection = [[RestfulConnection alloc] initWithUrl:baseUrl andAuthorizationToken:token];
    });
    
    describe(@"-initWithURL:andAuthorizationToken", ^{
        it(@"should create with url and authorization token", ^{
            [[connection shouldNot] beNil];
            [[connection.url should] equal:baseUrl];
            [[connection.authorizationToken should] equal:token];
        });
    });
    
    describe(@"-createRequestForEndpoint:", ^{
        
        beforeEach(^{
            mockRequest = [NSMutableURLRequest nullMock];
        });
        
        it(@"should create a http get request to endpoint using basic http authentication", ^{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/endpoint", baseUrl]];
            [[NSMutableURLRequest should] receive:@selector(requestWithURL:) andReturn:mockRequest withArguments:url];
            
            [[mockRequest should] receive:@selector(setValue:forKey:) andReturn:nil withArguments:@"Basic someToken", @"Authorization"];
            [[mockRequest should] receive:@selector(setHTTPMethod:) withArguments:@"GET"];
            
            [connection createRequestForEndpoint:@"/endpoint"];
        });
        
    });
    
    describe(@"-get:withSuccess:withFailure", ^{
        __block BOOL isSuccessfulCalled;
        __block BOOL isErrorCalled;
        
        beforeEach(^{
            mockRequest = [NSMutableURLRequest nullMock];
            isSuccessfulCalled = NO;
            isErrorCalled      = NO;
            [[connection should] receive:@selector(createRequestForEndpoint:) andReturn:mockRequest];
        });
        
        context(@"when the request is successful", ^{
            
            beforeEach(^{
                
                // Arrange
                [NSURLConnection stub:@selector(sendAsynchronousRequest:queue:completionHandler:) withBlock:^id(NSArray *params) {
                    void (^completionHandler)(NSURLResponse *response, NSData *data, NSError *connectionError) = params[2];
                    completionHandler(nil, [NSData new], nil);
                    return nil;
                }];
            });
            
            it(@"should respond only on the success block", ^{
                
                // Act
                [connection get:@"/status" withSuccess:^(NSDictionary *jsonResponse) {
                    isSuccessfulCalled = YES;
                } withFailure:^(NSError *error) {
                    isErrorCalled = YES;
                }];
                
                // Assert
                [[theValue(isSuccessfulCalled) shouldEventually] beYes];
                [[theValue(isErrorCalled) shouldEventually] beNo];
            });
        });
        
        context(@"when the request is unsuccessful", ^{
            
            beforeEach(^{
                
                // Arrange
                [NSURLConnection stub:@selector(sendAsynchronousRequest:queue:completionHandler:) withBlock:^id(NSArray *params) {
                    void (^completionHandler)(NSURLResponse *response, NSData *data, NSError *connectionError) = params[2];
                    completionHandler(nil, nil, [NSError new]);
                    return nil;
                }];
            });
            
            it(@"should respond only on the failure block", ^{
                
                // Act
                [connection get:@"/status" withSuccess:^(NSDictionary *jsonResponse) {
                    isSuccessfulCalled = YES;
                } withFailure:^(NSError *error) {
                    isErrorCalled = YES;
                }];
                
                // Assert
                [[theValue(isSuccessfulCalled) shouldEventually] beNo];
                [[theValue(isErrorCalled) shouldEventually] beYes];
            });
        });
        
    });
});

SPEC_END