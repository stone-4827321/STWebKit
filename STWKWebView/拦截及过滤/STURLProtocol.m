//
//  STURLProtocol.m
//  STWKWebView
//
//  Created by stone on 2018/11/8.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STURLProtocol.h"
#import <UIKit/UIKit.h>


static NSString *const STRecursiveRequestFlagProperty = @"FilteredKey";

@implementation STURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *extension = request.URL.pathExtension;
    NSArray *images = @[@"png", @"jpeg", @"gif", @"jpg"];
    if (![images containsObject:extension]) {
        return NO;
    }
    
    // 如果是startLoading里发起的request则忽略掉，避免死循环
    if ([self propertyForKey:STRecursiveRequestFlagProperty inRequest:request]) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest* request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:STRecursiveRequestFlagProperty inRequest:request];
    
    NSData*data = UIImagePNGRepresentation([UIImage imageNamed:@"1.png"]);
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
}


@end
