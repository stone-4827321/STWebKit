//
//  STViewController8.m
//  STWKWebView
//
//  Created by stone on 2018/11/8.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STViewController8.h"
#import <WebKit/WebKit.h>
#import "STURLProtocol.h"


@interface STViewController8 ()<WKURLSchemeHandler>

@end

@implementation STViewController8

- (void)dealloc
{
    NSArray *schemes = @[@"http", @"https"];
    for (NSString *scheme in schemes) {
        [self unregisterScheme:scheme];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"ios11" style:UIBarButtonItemStylePlain target:self action:@selector(scheme1)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"ios11以下" style:UIBarButtonItemStylePlain target:self action:@selector(scheme2)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"过滤" style:UIBarButtonItemStylePlain target:self action:@selector(filter)];

    self.navigationItem.rightBarButtonItems = @[item1, item2, item3];
}

#pragma mark - IOS11

- (void)scheme1
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    [configuration setURLSchemeHandler:self forURLScheme:@"stone"];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"local2" withExtension:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:webView];
}

#pragma mark WKURLSchemeHandler

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    NSURL *url = urlSchemeTask.request.URL;
    if ([url.scheme isEqualToString:@"stone"]) {
        UIImage *image = [UIImage imageNamed:url.resourceSpecifier];
        NSData *imageData = UIImagePNGRepresentation(image);
        if (imageData.length) {
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:url
                                                                MIMEType:@"image/png"
                                                   expectedContentLength:imageData.length
                                                        textEncodingName:nil];
            // 顺序必须先ReceiveResponse，再ReceiveData，最后Finish
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:imageData];
            [urlSchemeTask didFinish];
        }
        else {
            [urlSchemeTask didFailWithError:[[NSError alloc] init]];
        }
    }
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    
}

#pragma mark - IOS11以下

- (void)scheme2
{
    [NSURLProtocol registerClass:[STURLProtocol class]];

    NSArray *schemes = @[@"http", @"https"];
    for (NSString *scheme in schemes) {
        [self registerScheme:scheme];
    }
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.qq.com"]]];
    [self.view addSubview:webView];
}

- (void)registerScheme:(NSString *)scheme
{
    //Class cls = NSClassFromString(@"WKBrowsingContextController");
    Class cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([cls respondsToSelector:sel]) {
        [cls performSelector:sel withObject:scheme];
    }
}

- (void)unregisterScheme:(NSString *)scheme
{
    //Class cls = NSClassFromString(@"WKBrowsingContextController");
    Class cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    if ([cls respondsToSelector:sel]) {
        [cls performSelector:sel withObject:scheme];
    }
}


#pragma mark - 过滤

- (void)filter
{
    NSArray *array = @[@{@"trigger" : @{@"url-filter" : @".*", @"resource-type" : @[@"image"]},
                         @"action" : @{@"type" : @"block"}}];
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    // 添加规则
    WKContentRuleListStore *ruleListStore = [WKContentRuleListStore defaultStore];
    [ruleListStore compileContentRuleListForIdentifier:@"filterImage" encodedContentRuleList:json completionHandler:^(WKContentRuleList *list, NSError *error) {
        // 应用规则
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addContentRuleList:list];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = userContentController;
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.qq.com"]]];
        [self.view addSubview:webView];
    }];
}

@end
