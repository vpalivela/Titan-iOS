//
//  ManagedPasteboardSpec.m
//  TitanIOS
//
//  Created by venkat on 5/1/14.
//  Copyright (c) 2014 Venkat Palivela. All rights reserved.
//

#import "Kiwi.h"
#import <UIKit/UIKit.h>
#import "ManagedPasteboard.h"

@interface ManagedPasteboard (Testing)

@property UIPasteboard *pasteboard;
@property NSMutableDictionary *contents;

- (void)writeOperationWithData:(NSData *)data forKey:(NSString *)key;
- (id)performwithCallback:(id)callback operation:(id(^)(void))operationBlock;
@end

SPEC_BEGIN(ManagedPasteboardSpec)

__block ManagedPasteboard *managedPasteboard;
__block UIPasteboard *mockPasteboard;

beforeEach(^{
    mockPasteboard = [UIPasteboard nullMock];
    [UIPasteboard stub:@selector(pasteboardWithName:create:) andReturn:mockPasteboard withArguments:@"MyTestPasteboard", theValue(YES)];
    [[mockPasteboard should] receive:@selector(setPersistent:) withArguments:theValue(YES)];
    managedPasteboard = [[ManagedPasteboard alloc] initWithPasteboardName:@"MyTestPasteboard"];
});

describe(@"constructor", ^{
    
    it(@"should initalize with pasteboard name", ^{
        [[managedPasteboard shouldNot] beNil];
        [[managedPasteboard.pasteboard should] equal:mockPasteboard];
    });
    
    it(@"should initalize the internal dictionary", ^{
        [[managedPasteboard.contents shouldNot] beNil];
        [[[managedPasteboard.contents should] have:0] items];
    });
});

describe(@"instance methods", ^{
    it(@"should handle async read", ^{
        id callbackMock = [KWMock nullMockForProtocol:@protocol(StorageOperation)];
        [[callbackMock shouldEventuallyBeforeTimingOutAfter(5)] receive:@selector(readCompleted:)];
        NSData *value = [managedPasteboard read:@"test" withCallBack:callbackMock];
        [[value should] beNil];
    });
    
    it(@"should handle sync read", ^{
        NSData *value = [managedPasteboard read:@"test" withCallBack:nil];
        [[value shouldNot] beNil];
        [[value should] equal:[NSData data]];
    });
    
    it(@"should handle sync write", ^{
        [[managedPasteboard should] receive:@selector(writeOperationWithData:forKey:) withArguments:[NSData data], @"someKey"];
        [managedPasteboard writeData:[NSData data] forKey:@"someKey" withCallback:nil];
    });
    
    it(@"should handle async write", ^{
        id callbackMock = [KWMock nullMockForProtocol:@protocol(StorageOperation)];
        [[callbackMock shouldEventuallyBeforeTimingOutAfter(5)] receive:@selector(writeCompleted)];

//        [[managedPasteboard should] receive:@selector(performwithCallback:operation:)];
//        [[managedPasteboard should] receive:@selector(writeOperationWithData:forKey:) withArguments:[NSData data], @"someKey"];

        
        [managedPasteboard writeData:[NSData data] forKey:@"someKey" withCallback:callbackMock];
    });
});

SPEC_END