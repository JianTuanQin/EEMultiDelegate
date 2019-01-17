//
//  EEMultiProxy.m
//
//  a multicast delegate class with thread-safe
//
//  Created by ian  on 2017/9/9.
//  Copyright © 2017 ian<https://github.com/ienho>. All rights reserved.
//

#import "EEMultiProxy.h"

@implementation EEMultiProxy {
    NSHashTable *_delegates;
    dispatch_semaphore_t _semaphore;
}

#pragma mark - Public Methods

+ (id)alloc {
    EEMultiProxy *instance = [super alloc];
    if (instance) {
        instance->_semaphore = dispatch_semaphore_create(1);
        instance->_delegates = [NSHashTable weakObjectsHashTable];
    }
    return instance;
}

+ (EEMultiProxy *)proxy {
    return [EEMultiProxy alloc];
}

- (void)addDelegate:(id)delegate {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates addObject:delegate];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeDelete:(id)delegate {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates removeObject:delegate];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeAllDelegates {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_delegates removeAllObjects];
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark - Forward Methods

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMethodSignature *methodSignature;
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:selector]) {
            methodSignature = [delegate methodSignatureForSelector:selector];
            break;
        }
    }
    dispatch_semaphore_signal(_semaphore);
    if (methodSignature) return methodSignature;
    
    // Avoid crash, must return a methodSignature "- (void)method"
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSHashTable *copyDelegates = [_delegates copy];
    dispatch_semaphore_signal(_semaphore);
    
    SEL selector = invocation.selector;
    for (id delegate in copyDelegates) {
        if ([delegate respondsToSelector:selector]) {
            // must use duplicated invocation when you invoke with async
            NSInvocation *dupInvocation = [self duplicateInvocation:invocation];
            dupInvocation.target = delegate;
            if (_runInMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dupInvocation invoke];
                });
            }else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [dupInvocation invoke];
                });
            }
        }
    }
}

- (NSInvocation *)duplicateInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    NSMethodSignature *methodSignature = invocation.methodSignature;
    NSInvocation *dupInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    dupInvocation.selector = selector;
    
    NSUInteger count = methodSignature.numberOfArguments;
    for (NSUInteger i = 2; i < count; i++) {
        void *value;
        [invocation getArgument:&value atIndex:i];
        [dupInvocation setArgument:&value atIndex:i];
    }
    [dupInvocation retainArguments];
    return dupInvocation;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return YES;
}

@end
