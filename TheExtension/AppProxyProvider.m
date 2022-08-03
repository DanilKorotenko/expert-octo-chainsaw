#import "AppProxyProvider.h"

API_AVAILABLE(macos(11.0))
@implementation AppProxyProvider
{
    dispatch_queue_t _queue;
}

- (NENetworkRule *)ruleWithPort:(NSUInteger)port
    proto:(NENetworkRuleProtocol)proto
{
    NWHostEndpoint *endpoint = nil;

    // Port 0 mean that rule catches all port range.
    if (port != 0)
    {
        endpoint = [NWHostEndpoint endpointWithHostname:@"0.0.0.0"
            port:@(port).stringValue];
    }

    return [[NENetworkRule alloc]
        initWithRemoteNetwork:endpoint
            remotePrefix:0
            localNetwork:nil
            localPrefix:0
            protocol:proto
            direction:NETrafficDirectionOutbound];
}

- (NENetworkRule *)ruleWithHost:(NSString *)host
                      prefixLen:(NSUInteger)prefix
                           port:(NSUInteger)port
                          proto:(NENetworkRuleProtocol)proto
{
    return [[NENetworkRule alloc] initWithRemoteNetwork:
        [NWHostEndpoint endpointWithHostname:host port:@(port).stringValue]
        remotePrefix:prefix
        localNetwork:nil
        localPrefix:0
        protocol:proto
        direction:NETrafficDirectionOutbound];
}

- (void)startProxyWithOptions:(NSDictionary *)options
    completionHandler:(void (^)(NSError *))completionHandler
{
    NETransparentProxyNetworkSettings *settings =
        [[NETransparentProxyNetworkSettings alloc]
            initWithTunnelRemoteAddress:@"127.0.0.1"];

    settings.includedNetworkRules =
        @[
            [self ruleWithPort:0 proto:NENetworkRuleProtocolTCP],
        ];

    [self setTunnelNetworkSettings:settings completionHandler:
        ^(NSError * _Nullable error)
        {
            if (error)
            {
                NSLog(@"setTunnelNetworkSettings: %@", error.localizedDescription);
            }
        }];

    _queue = dispatch_queue_create(nil, nil);

    if (completionHandler != nil)
    {
        completionHandler(nil);
    }
}

- (void)stopProxyWithReason:(NEProviderStopReason)reason
    completionHandler:(void (^)(void))completionHandler
{
    if (completionHandler != nil)
    {
        completionHandler();
    }
}

- (void)handleAppMessage:(NSData *)messageData
    completionHandler:(void (^)(NSData *))completionHandler
{
    if (completionHandler != nil)
    {
        completionHandler(messageData);
    }
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
    if (completionHandler != nil)
    {
        completionHandler();
    }
}

- (void)wake
{
    // Add code here to wake up.
}

- (BOOL)handleNewFlow:(NEAppProxyFlow *)flow
{
    // Just bypass everything -- enough to reproduce some bugs
    return NO;
}

@end
