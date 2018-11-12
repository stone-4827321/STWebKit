//
//  STViewController7.m
//  STWKWebView
//
//  Created by stone on 2018/11/7.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STViewController7.h"
#import <WebKit/WebKit.h>

@interface STViewController7 () <WKNavigationDelegate>

@end

@implementation STViewController7

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"ui" style:UIBarButtonItemStylePlain target:self action:@selector(uiwebviewTest)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"wk" style:UIBarButtonItemStylePlain target:self action:@selector(wkwebviewTest)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"fix1" style:UIBarButtonItemStylePlain target:self action:@selector(wkwebviewFixTest1)];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"fix2" style:UIBarButtonItemStylePlain target:self action:@selector(wkwebviewFixTest2)];

    self.navigationItem.rightBarButtonItems = @[item1, item2, item3, item4];
    
    
}

- (void)uiwebviewTest
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/post"]];
    request.HTTPMethod = @"POST";
    [request setHTTPBody:[@"name=stone" dataUsingEncoding:NSUTF8StringEncoding]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

- (void)wkwebviewTest
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/post"]];
    request.HTTPMethod = @"POST";
    [request setHTTPBody:[@"name=stone" dataUsingEncoding:NSUTF8StringEncoding]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

- (void)wkwebviewFixTest1
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/post"]];
    request.HTTPMethod = @"POST";
    [request setHTTPBody:[@"name=stone" dataUsingEncoding:NSUTF8StringEncoding]];
//    [webView loadRequest:request];
    [self.view addSubview:webView];
    
    // 实例化网络会话
    NSURLSession *session = [NSURLSession sharedSession];
    // 创建请求Task
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 将请求到的网页数据用loadHTMLString 的方法加载
        NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView loadHTMLString:htmlStr baseURL:nil];
        });
    }];
    // 开启网络任务
    [task resume];
}

- (void)wkwebviewFixTest2
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"local4" withExtension:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:webView];
    webView.navigationDelegate = self;

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([webView.URL.lastPathComponent isEqualToString:@"local4.html"]) {
        // 发送POST的参数
        NSString *postData = @"'name':'stone'";
        // 请求的页面地址
        NSString *urlStr = @"https://httpbin.org/post";
        // 拼装成调用JavaScript的字符串
        NSString *jscript = [NSString stringWithFormat:@"post('%@', {%@});", urlStr, postData];
        // 调用JS代码
        [webView evaluateJavaScript:jscript completionHandler:nil];
    }
}

@end
