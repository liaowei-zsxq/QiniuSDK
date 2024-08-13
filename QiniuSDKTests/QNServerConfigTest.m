//
//  QNServerConfigTest.m
//  QiniuSDK
//
//  Created by yangsen on 2021/9/22.
//  Copyright © 2021 Qiniu. All rights reserved.
//

#import "QNTestConfig.h"
#import "QNServerConfigCache.h"
#import "QNServerConfigMonitor.h"
#import "QNServerConfigSynchronizer.h"
#import <XCTest/XCTest.h>
#import <AGAsyncTestHelper.h>
#import "XCTestCase+QNTest.h"

#import "QNLogUtil.h"

@interface QNServerConfigTest : XCTestCase

@end

@implementation QNServerConfigTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

//- (void)testMonitor {
//    [QNServerConfigMonitor startMonitor];
//    QNServerConfigMonitor.token = token_na0;
//    AGWW_WAIT_WHILE(true, 30);
//}

- (void)testServerConfigProperty {
    dispatch_group_t group = dispatch_group_create();
    
    for (int i=0; i<1000; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            dispatch_group_enter(group);
            for (int j=0; j<10000; j++) {
                NSString *token = QNServerConfigSynchronizer.token;
                if (token.length > 0) {
                    token = [token substringToIndex:1];
                }
                NSString *newToken = [NSString stringWithFormat:@"%@-%d-%d", token, i, j];
                QNServerConfigSynchronizer.token = newToken;
            }
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"testServerConfigProperty complete");
    });
    
    QN_TEST_CASE_WAIT_TIME(2);
}

- (void)testServerConfigModel {
    NSString *serverConfigJsonString = @"{\"ttl\": 86400,\"region\": {\"clear_id\": 10,\"clear_cache\": true},\"dns\": {\"enabled\": true,\"clear_id\": 10,\"clear_cache\": true,\"doh\": {\"enabled\": true,\"ipv4\": {\"override_default\": true,\"urls\": [\"https://223.5.5.5/dns-query\"]},\"ipv6\": {\"override_default\": true,\"urls\": [\"https://FFAE::EEEE/dns-query\"]}},\"udp\": {\"enabled\": true,\"ipv4\": {\"ips\": [\"223.5.5.5\", \"1.1.1.1\"],\"override_default\": true},\"ipv6\": {\"ips\": [\"FFAE::EEEE\"],\"override_default\": true}}},\"connection_check\": {\"override_default\": true,\"enabled\": true,\"timeout_ms\": 3000,\"urls\": [\"a.com\", \"b.com\"]}}";
    NSDictionary *serverConfigInfo = [NSJSONSerialization JSONObjectWithData:[serverConfigJsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    QNServerConfig *serverConfig = [QNServerConfig config:serverConfigInfo];
    XCTAssertTrue(serverConfig != nil, "server config was nil");
    XCTAssertTrue(serverConfig.ttl > 0, "server config ttl was nil");
    XCTAssertTrue(serverConfig.dnsConfig != nil, "server config dns config was nil");
    XCTAssertTrue(serverConfig.dnsConfig.enable != nil, "server config dns config enable was nil");
    XCTAssertTrue(serverConfig.dnsConfig.clearId > 0, "server config dns config clearId was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig != nil, "server config udp dns config was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig.enable != nil, "server config udp dns config enable was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig.ipv4Server != nil, "server config udp dns config ipv4Server was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig.ipv4Server.isOverride, "server config udp dns config ipv4Server override default was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig.ipv4Server.servers != nil, "server config udp dns config ipv4Server servers was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig.ipv6Server != nil, "server config udp dns config ipv6Server was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig.ipv6Server.isOverride, "server config udp dns config ipv6Server override default was nil");
    XCTAssertTrue(serverConfig.dnsConfig.udpConfig.ipv6Server.servers != nil, "server config udp dns config ipv6Server servers was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig != nil, "server config doh dns config was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig.enable != nil, "server config doh dns config enable was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig.ipv4Server != nil, "server config doh dns config ipv4Server was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig.ipv4Server.isOverride, "server config doh dns config ipv4Server override default was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig.ipv4Server.servers != nil, "server config doh dns config ipv4Server servers was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig.ipv6Server != nil, "server config doh dns config ipv6Server was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig.ipv6Server.isOverride, "server config doh dns config ipv6Server override default was nil");
    XCTAssertTrue(serverConfig.dnsConfig.dohConfig.ipv6Server.servers != nil, "server config doh dns config ipv6Server servers was nil");
    XCTAssertTrue(serverConfig.regionConfig != nil, "server config region config was nil");
    XCTAssertTrue(serverConfig.regionConfig.clearId > 0, "server config region config clearId was nil");
    XCTAssertTrue(serverConfig.connectCheckConfig != nil, "connect check config was nil");
    XCTAssertTrue(serverConfig.connectCheckConfig.isOverride, "connect check config isOverride was false");
    XCTAssertTrue(serverConfig.connectCheckConfig.enable, "connect check config enabled was false");
    XCTAssertTrue(serverConfig.connectCheckConfig.timeoutMs.integerValue == 3000, "connect check config timeoutMs was not 3000");
    XCTAssertTrue(serverConfig.connectCheckConfig.urls && [serverConfig.connectCheckConfig.urls containsObject:@"a.com"], "connect check config urls was wrong");
    
    NSString *serverUserConfigJsonString = @"{\"ttl\":86400,\"http3\":{\"enabled\":true},\"network_check\":{\"enabled\":true}}";
    NSDictionary *serverUserConfigInfo = [NSJSONSerialization JSONObjectWithData:[serverUserConfigJsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    QNServerUserConfig *serverUserConfig = [QNServerUserConfig config:serverUserConfigInfo];
    XCTAssertTrue(serverUserConfig != nil, "server user config was nil");
    XCTAssertTrue(serverUserConfig.ttl > 0, "server user config ttl was nil");
    XCTAssertTrue(serverUserConfig.http3Enable != nil, "server user config http3Enable was nil");
    XCTAssertTrue(serverUserConfig.networkCheckEnable != nil, "server user config networkCheckEnable was nil");
}


@end
