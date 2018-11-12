//
//  STViewController3.m
//  STWKWebView
//
//  Created by stone on 2018/11/5.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STViewController3.h"
#import <WebKit/WebKit.h>

#define IS_IOS9orHIGHER (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_x_Max)

#define IS_IOS8orHIGHER (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)

@interface STViewController3 () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation STViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"%@", NSHomeDirectory());

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _configuration = configuration;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dev.skyfox.org/cookie.php"]]];
    [self.view addSubview:webView];
    webView.UIDelegate = self;
    _webView = webView;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"查缓" style:UIBarButtonItemStylePlain target:self action:@selector(checkCache)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"清缓" style:UIBarButtonItemStylePlain target:self action:@selector(deleteCache)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"查Co" style:UIBarButtonItemStylePlain target:self action:@selector(checkCookie)];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"加Co" style:UIBarButtonItemStylePlain target:self action:@selector(addCookie)];
    UIBarButtonItem *item5 = [[UIBarButtonItem alloc] initWithTitle:@"删Co" style:UIBarButtonItemStylePlain target:self action:@selector(deleteCookie)];

    self.navigationItem.rightBarButtonItems = @[item1, item2, item3, item4, item5];
}

- (void)checkCache
{
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];//_configuration.dataStore;
    [dataStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray *records) {
                         for (WKWebsiteDataRecord *record  in records) {
                             NSLog(@"%@ %@", record.displayName, record.dataTypes);
                         }
                     }];
}


- (void)deleteCache
{
#ifdef __IPHONE_9_0
    //指定类型
    //NSArray *types = @[WKWebsiteDataTypeCookies, WKWebsiteDataTypeLocalStorage];
    //NSSet *websiteDataTypes = [NSSet setWithArray:types];
    //全部类型
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];//_configuration.dataStore;
    [dataStore removeDataOfTypes:websiteDataTypes
                   modifiedSince:dateFrom
               completionHandler:^{
                   NSLog(@"清除缓存完毕");
               }];
#else
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *libraryDir = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit", libraryDir];
    NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit", libraryDir, bundleId];
    [manager removeItemAtPath:webKitFolderInCaches error:nil];
    [manager removeItemAtPath:webkitFolderInLib error:nil];
    
    // ios7
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData", libraryDir, bundleId];
    [manager removeItemAtPath:webKitFolderInCachesfs error:nil];
#endif
}

- (void)checkCookie
{
    WKHTTPCookieStore *cookieStore = _configuration.websiteDataStore.httpCookieStore;
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * list) {
        for (NSHTTPCookie *cookie in list) {
            NSLog(@"%@ %@ %@", cookie.name, cookie.value, cookie.domain);
        }
    }];
}

- (void)addCookie
{
//    WKUserContentController *userContentController = WKUserContentController.new;
//    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource: @"document.cookie ='TeskCookieKey=TeskCookieValue';"injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//    [userContentController addUserScript:cookieScript];
//
//    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
//    webViewConfig.userContentController = userContentController;
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webViewConfig];
//
//    NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dev.skyfox.org/cookie.php"]];
//    [request setValue:[NSString stringWithFormat:@"%@=%@",@"TeskCookieKey", @"TeskCookieValue"] forHTTPHeaderField:@"Cookie"];
//    [webView loadRequest:request];
//    [self.view addSubview:webView];
//    webView.UIDelegate = self;
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"TeskCookieKey" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"TeskCookieValue" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"dev.skyfox.org" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:[NSDate dateWithTimeIntervalSinceNow:60 * 60] forKey:NSHTTPCookieExpires];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    WKHTTPCookieStore *cookieStore = _configuration.websiteDataStore.httpCookieStore;
    [cookieStore setCookie:cookie completionHandler:^{
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webViewConfig];
        NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dev.skyfox.org/cookie.php"]];
        [webView loadRequest:request];
        [self.view addSubview:webView];
        webView.UIDelegate = self;
    }];
}

- (void)deleteCookie
{
    WKHTTPCookieStore *cookieStore = _configuration.websiteDataStore.httpCookieStore;
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * list) {
        for (NSHTTPCookie *cookie in list) {
            NSLog(@"%@ %@ %@", cookie.name, cookie.value, cookie.domain);
            [cookieStore deleteCookie:cookie completionHandler:nil];
        }
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              completionHandler();
                                                          }];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"title"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:confirmAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}
@end
