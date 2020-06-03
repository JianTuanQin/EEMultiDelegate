//
//  NSObject+EEMultiProxyAdditions.h
//  A multicast-delegate function additions
//
//  Created by ian<https://github.com/ienho>. on 2019/7/8.
//  Copyright © 2019 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEMultiProxy.h"

NS_ASSUME_NONNULL_BEGIN

#define EEProxy(Protocol) ((id<Protocol>)self.ee_multiProxy)

/// A multicast-delegate function additions
@interface NSObject (EEMultiProxyAdditions)

/// Multicast-delegate proxy
@property (nonatomic, readonly) EEMultiProxy *ee_multiProxy;

/// Add a delegate to the proxy
/// @param delegate : custom delegate
- (void)ee_addDelegate:(id /* id<Protocol> */ )delegate;

/// Remove a delegate from the proxy
/// @param delegate : custom delegate
- (void)ee_removeDelegate:(id /* id<Protocol> */ )delegate;

/// Remove all delegates from the proxy
- (void)ee_removeAllDelegates;

@end

NS_ASSUME_NONNULL_END
