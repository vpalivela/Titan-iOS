//
//  ManagedPasteboard.m
//  TitanIOS
//
//  Created by venkat on 5/1/14.
//  Copyright (c) 2014 Venkat Palivela. All rights reserved.
//

#import "ManagedPasteboard.h"
#import <UIKit/UIKit.h>


@interface ManagedPasteboard ()

@property UIPasteboard *pasteboard;
@property NSMutableDictionary *contents;

@end

@implementation ManagedPasteboard

- (instancetype)initWithPasteboardName:(NSString *) pasteboardName
{
    self = [super self];
    
    if (self) {
        self.pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
        self.pasteboard.persistent = YES;
        
        self.contents = [NSMutableDictionary new];
    }
    
    return self;
}


@end
