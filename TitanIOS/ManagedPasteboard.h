//
//  ManagedPasteboard.h
//  TitanIOS
//
//  Created by venkat on 5/1/14.
//  Copyright (c) 2014 Venkat Palivela. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StorageOperation <NSObject>

- (void)readCompleted:(NSData *)data;
- (void)writeCompleted;

@end

@interface ManagedPasteboard : NSObject

// Lifecycle Methods

- (instancetype)initWithPasteboardName:(NSString *) pasteboardName;

// Instance Methods
- (NSData *) read:(NSString *)key withCallBack:(id<StorageOperation>)callback;
- (void)writeData:(NSData *)data forKey:(NSString *)key withCallback:(id<StorageOperation>)callback;

@end

