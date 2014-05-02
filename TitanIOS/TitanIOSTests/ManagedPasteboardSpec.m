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

//describe(@"instance methods", ^{
//    
//});

SPEC_END