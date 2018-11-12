//
//  STViewController1.m
//  STWKWebView
//
//  Created by stone on 2018/11/2.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STViewController1.h"
#import <WebKit/WebKit.h>

@interface STViewController1 ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation STViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    //配置
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    
    //配置的线程池
    WKProcessPool *processPool = [[WKProcessPool alloc] init];
    configuration.processPool  = processPool;
    //配置的偏好设置
    WKPreferences *preferences = [[WKPreferences alloc] init];
    configuration.preferences = preferences;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.mozilla.org/~rnewman/fennec/mem.html"]]];
    [self.view addSubview:webView];
    _webView = webView;
    
    webView.allowsBackForwardNavigationGestures = YES;
    
    //监听进度
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(reload:)];
    UIBarButtonItem *goBackItem = [[UIBarButtonItem alloc] initWithTitle:@"上一页"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(goBack:)];
    UIBarButtonItem *goForwardItem = [[UIBarButtonItem alloc] initWithTitle:@"下一页"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(goForward:)];
    UIBarButtonItem *historyItem = [[UIBarButtonItem alloc] initWithTitle:@"历史"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(history:)];
    self.navigationItem.rightBarButtonItems = @[reloadItem, goBackItem, goForwardItem, historyItem];

}

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id)urlSchemeTask
{
    
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // 进度条
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"%f", self.webView.estimatedProgress);
    }
}



#pragma mark - Action

// 刷新
- (void)reload:(id)sender
{
    if (self.webView.loading) {
        [self.webView stopLoading];
    }
    
    [self.webView reload];
}

// 上一页
- (void)goBack:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

// 下一页
- (void)goForward:(id)sender
{
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)history:(id)sender
{
    WKBackForwardList *backForwardList = self.webView.backForwardList;
    
    // 历史
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"浏览记录" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak WKWebView *webView = self.webView;
    // 后退
    for (__weak WKBackForwardListItem *backItem in backForwardList.backList) {
        [alertController addAction:[UIAlertAction actionWithTitle:backItem.URL.absoluteString
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [webView goToBackForwardListItem:backItem];
                                                          }]];
    }
    // 前进
    for (__weak WKBackForwardListItem *forwardItem in backForwardList.forwardList) {
        [alertController addAction:[UIAlertAction actionWithTitle:forwardItem.URL.absoluteString
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [webView goToBackForwardListItem:forwardItem];
                                                          }]];
    }
    // 取消按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    // 显示
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
