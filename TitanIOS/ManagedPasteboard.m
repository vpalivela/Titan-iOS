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

@implementation ManagedPasteboard {
    dispatch_queue_t _queue;
}

- (instancetype)initWithPasteboardName:(NSString *) pasteboardName
{
    self = [super self];
    
    if (self) {
        self.pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
        self.pasteboard.persistent = YES;
        
        self.contents = [NSMutableDictionary new];
        _queue = dispatch_queue_create("com.titanios.storagequeue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void) dealloc {
    _queue = nil;
}

- (NSData *) read:(NSString *)key withCallBack:(id<StorageOperation>)callback {
    return (NSData *) [self onCallback:callback performSelector:@selector(readCompleted:) afterOperation:^id{
        return [self readOperation];
    }];
}

- (void)writeData:(NSData *)data forKey:(NSString *)key withCallback:(id<StorageOperation>)callback {
    [self onCallback:callback performSelector:@selector(writeCompleted) afterOperation:^id{
        [self writeOperationWithData:data forKey:key];
        return nil;
    }];

}

#pragma mark - Internal Helper Methods

- (id)onCallback:(id)callback
           performSelector:(SEL)callBackSelector afterOperation:(id(^)(void))operationBlock {
    __block id returnValue;
    if(callback){
        dispatch_async(_queue, ^{
            //TODO something
            returnValue = operationBlock();
            dispatch_async(dispatch_get_main_queue(), ^{
                if(returnValue){
                    [callback performSelector:callBackSelector withObject:returnValue];
                } else {
                    [callback performSelector:callBackSelector];
                }
            });
        });
    } else {
        dispatch_sync(_queue, ^{
            returnValue = operationBlock();
        });
    }
    return returnValue;
}

- (NSData *) readOperation {
    // Simulating delay for now
    [NSThread sleepForTimeInterval:1.0f];
    return [NSData data];
}

- (void) writeOperationWithData:(NSData *)data forKey:(NSString *)key {
    // Simulating delay for now
    [NSThread sleepForTimeInterval:3.0f];
}

@end
