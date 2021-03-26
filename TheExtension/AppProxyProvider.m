#import "AppProxyProvider.h"

API_AVAILABLE(macos(11.0))
@implementation AppProxyProvider {
    dispatch_queue_t _queue;
}

- (NENetworkRule *)ruleWithHost:(NSString *)host
                      prefixLen:(NSUInteger)prefix
                           port:(NSUInteger)port
                          proto:(NENetworkRuleProtocol)proto {
    return [[NENetworkRule alloc] initWithRemoteNetwork:[NWHostEndpoint endpointWithHostname:host
                                                                                        port:@(port).stringValue]
                                           remotePrefix:prefix
                                           localNetwork:nil
                                            localPrefix:0
                                               protocol:proto
                                              direction:NETrafficDirectionOutbound];
}

- (void)startProxyWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    NETransparentProxyNetworkSettings *settings =
            [[NETransparentProxyNetworkSettings alloc] initWithTunnelRemoteAddress:@"127.0.0.1"];
    
    settings.includedNetworkRules = @[
        [self ruleWithHost:@"2000::"    prefixLen:3 port:0 proto:NENetworkRuleProtocolTCP],
        
        // 0.0.0.0/0 - 224.0.0.0/3 - 0.0.0.0/8
        [self ruleWithHost:@"1.0.0.0"   prefixLen:8 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"2.0.0.0"   prefixLen:7 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"4.0.0.0"   prefixLen:6 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"8.0.0.0"   prefixLen:5 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"16.0.0.0"  prefixLen:4 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"32.0.0.0"  prefixLen:3 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"64.0.0.0"  prefixLen:2 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"128.0.0.0" prefixLen:2 port:0 proto:NENetworkRuleProtocolTCP],
        [self ruleWithHost:@"192.0.0.0" prefixLen:3 port:0 proto:NENetworkRuleProtocolTCP],
    ];
    
    [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"setTunnelNetworkSettings: %@", error.localizedDescription);
        }
    }];
    
    _queue = dispatch_queue_create(nil, nil);
    
    if (completionHandler != nil) {
        completionHandler(nil);
    }
}

- (void)stopProxyWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
    if (completionHandler != nil) {
        completionHandler();
    }
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
    if (completionHandler != nil) {
        completionHandler(messageData);
    }
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
    if (completionHandler != nil) {
        completionHandler();
    }
}

- (void)wake {
    // Add code here to wake up.
}

- (BOOL)handleNewFlow:(NEAppProxyFlow *)flow {
    // Just bypass everything -- enough to reproduce some bugs
    return NO;
}

@end
