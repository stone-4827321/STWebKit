//
//  STViewController2.m
//  STWKWebView
//
//  Created by stone on 2018/11/2.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STViewController4.h"
#import <WebKit/WebKit.h>

@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

@end

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end



@interface STViewController4 ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation STViewController4

- (void)dealloc
{
    //[self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"stone"];
    NSLog(@"delloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"JS注入" style:UIBarButtonItemStylePlain target:self action:@selector(inject)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"OC调用JS" style:UIBarButtonItemStylePlain target:self action:@selector(OCCallJS)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"JS调用OC" style:UIBarButtonItemStylePlain target:self action:@selector(JSCallOC)];
    self.navigationItem.rightBarButtonItems = @[item1, item2, item3];
}

- (void)inject
{
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    //JavaScript 注入:设定图片宽度
    NSString *javaScriptSource = @"var count = document.images.length;\
                                   for(var i = 0; i < count; i++) { \
                                   var image = document.images[i];\
                                   image.style.width=100;\
                                   };";

    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
    [userContentController addUserScript:userScript];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;

    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [webView loadHTMLString:@"<head></head><img src='http://upload-images.jianshu.io/upload_images/2317908-62d2d56a1751f4db.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240' />"baseURL:nil];
    [self.view addSubview:webView];
}

- (void)OCCallJS
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [self.view addSubview:webView];
    
    //NSString *javaScript = @"function hi() { alert('123') } hi()";
    NSString *javaScript = @"function hi() { return 'hi' } hi()";

    [webView evaluateJavaScript:javaScript completionHandler:^(id object, NSError *error) {
        NSLog(@"%@",object);
        // 输出 hi
    }];
}

- (void)JSCallOC
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    configuration.userContentController = userContentController;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"JSCallOC" withExtension:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:webView];
    _webView = webView;
    
//    [userContentController addScriptMessageHandler:self name:@"stone"];
//
    WeakScriptMessageDelegate *weakSelf = [[WeakScriptMessageDelegate alloc] initWithDelegate:self];
    [userContentController addScriptMessageHandler:weakSelf name:@"stone"];
}

#pragma mark - WKScriptMessageHandler

//WKScriptMessageHandler协议的方法，获取到JavaScript传递进来的消息时触发
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"name: %@，body: %@", message.name, message.body);
    //输出 name: stone，body: {name = stone;}
}
@end
