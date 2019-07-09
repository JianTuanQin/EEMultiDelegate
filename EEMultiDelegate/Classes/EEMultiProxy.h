//
//  EEMultiProxy.h
//
//  A multicast delegate class with thread-safe
//
//  Created by ian<https://github.com/ienho> on 2017/9/9.
//  Copyright © 2017 ian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EEMultiProxy : NSProxy

/**
 By default (YES), the proxy will invoke methods in main thread
 */
@property (nonatomic, assign) BOOL runInMainThread;

/**
 Create a EEMultiProxy instance when you add the multicast delegate funciton to your class

 @return new instance
 */
+ (EEMultiProxy *)proxy;

/**
 Add a delegate to the list
 */
- (void)addDelegate:(id)delegate;

/**
 Remove a delegate from the list
 */
- (void)removeDelete:(id)delegate;


/**
 Remove all delegates from the list
 */
- (void)removeAllDelegates;

@end
