//
//  QNCFHttpClient.m
//  QiniuSDK
//
//  Created by yangsen on 2021/10/11.
//  Copyright © 2021 Qiniu. All rights reserved.
//

#import "QNAsyncRun.h"
#import "QNCFHttpClient.h"
#import "QNCFHttpClientInner.h"
#import "NSURLRequest+QNRequest.h"
#import "QNUploadRequestMetrics.h"

@interface QNCFHttpClient() <QNCFHttpClientInnerDelegate>

@property(nonatomic, assign)BOOL hasCallBack;
@property(nonatomic, assign)NSInteger redirectCount;
@property(nonatomic, assign)NSInteger maxRedirectCount;

@property(nonatomic, strong)NSURLRequest *request;
@property(nonatomic, strong)NSURLResponse *response;
@property(nonatomic, strong)NSDictionary *connectionProxy;
@property(nonatomic, strong)QNUploadSingleRequestMetrics *requestMetrics;
@property(nonatomic, strong)NSMutableData *responseData;
@property(nonatomic,  copy)void(^progress)(long long totalBytesWritten, long long totalBytesExpectedToWrite);
@property(nonatomic,  copy)QNRequestClientCompleteHandler complete;

@property(nonatomic, strong)QNCFHttpClientInner *httpClient;

@end
@implementation QNCFHttpClient

+ (NSOperationQueue *)shareQueue {
    
    static NSOperationQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 6;
        queue.name = @"com.qiniu.cfclient";
    });
    return queue;
}

- (NSString *)clientId {
    return @"CFNetwork";
}

- (instancetype)init {
    if (self = [super init]) {
        self.redirectCount = 0;
        self.maxRedirectCount = 15;
        self.hasCallBack = false;
    }
    return self;
}

- (void)request:(NSURLRequest *)request
         server:(id <QNUploadServer>)server
connectionProxy:(NSDictionary *)connectionProxy
       progress:(void (^)(long long, long long))progress
       complete:(QNRequestClientCompleteHandler)complete {
    
    // 有 ip 才会使用
    if (server && server.ip.length > 0 && server.host.length > 0) {
        NSString *urlString = request.URL.absoluteString;
        urlString = [urlString stringByReplacingOccurrencesOfString:server.host withString:server.ip];
        NSMutableURLRequest *requestNew = [request mutableCopy];
        requestNew.URL = [NSURL URLWithString:urlString];
        requestNew.qn_domain = server.host;
        self.request = [requestNew copy];
    } else {
        self.request = request;
    }
    
    self.connectionProxy = connectionProxy;
    self.complete = complete;
    self.requestMetrics = [QNUploadSingleRequestMetrics emptyMetrics];
    self.requestMetrics.request = self.request;
    self.requestMetrics.remoteAddress = request.qn_ip;
    self.requestMetrics.remotePort = request.qn_isHttps ? @443 : @80;
    [self.requestMetrics start];
    
    self.responseData = [NSMutableData data];
    self.httpClient = [QNCFHttpClientInner client:request connectionProxy:connectionProxy];
    self.httpClient.delegate = self;
    [[QNCFHttpClient shareQueue] addOperation:self.httpClient];
}

- (void)cancel {
    [self.httpClient stopLoading];
}

- (void)completeAction:(NSError *)error {
    @synchronized (self) {
        if (self.hasCallBack) {
            return;
        }
        self.hasCallBack = true;
    }
    self.requestMetrics.response = self.response;
    [self.httpClient stopLoading];
    [self.requestMetrics end];
    if (self.complete) {
        self.complete(self.response, self.requestMetrics, self.responseData, error);
    }
}

//MARK: -- delegate
- (void)didSendBodyData:(int64_t)bytesSent
         totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    if (self.progress) {
        self.progress(totalBytesSent, totalBytesExpectedToSend);
    }
}

- (void)didFinish {
    self.requestMetrics.responseEndDate = [NSDate date];
    [self completeAction:nil];
}

- (void)didLoadData:(nonnull NSData *)data {
    [self.responseData appendData:data];
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }

    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);

    SecTrustResultType result = kSecTrustResultInvalid;
    
    OSStatus status = SecTrustEvaluate(serverTrust, &result);
    if (status != errSecSuccess) {
        return NO;
    }
    
    if (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed) {
        return YES;
    } else {
        return NO;
    }
}

- (void)onError:(nonnull NSError *)error {
    [self completeAction:error];
}

- (void)onReceiveResponse:(NSURLResponse *)response httpVersion:(NSString *)httpVersion{
    self.requestMetrics.responseStartDate = [NSDate date];
    if ([httpVersion isEqualToString:@"http/1.0"]) {
        self.requestMetrics.httpVersion = @"1.0";
    } else if ([httpVersion isEqualToString:@"http/1.1"]) {
        self.requestMetrics.httpVersion = @"1.1";
    } else if ([httpVersion isEqualToString:@"h2"]) {
        self.requestMetrics.httpVersion = @"2";
    } else if ([httpVersion isEqualToString:@"h3"]) {
        self.requestMetrics.httpVersion = @"3";
    } else {
        self.requestMetrics.httpVersion = httpVersion;
    }
    self.response = response;
}

- (void)redirectedToRequest:(nonnull NSURLRequest *)request redirectResponse:(nonnull NSURLResponse *)redirectResponse {
    if (self.redirectCount < self.maxRedirectCount) {
        [self.httpClient stopLoading];
        self.redirectCount += 1;
        [self request:request server:nil connectionProxy:self.connectionProxy progress:self.progress complete:self.complete];
    } else {
        [self didFinish];
    }
}

@end
