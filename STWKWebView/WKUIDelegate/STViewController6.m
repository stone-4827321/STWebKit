//
//  STViewController6.m
//  STWKWebView
//
//  Created by stone on 2018/11/6.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STViewController6.h"
#import <WebKit/WebKit.h>

@interface STWindowViewController : UIViewController

- (instancetype)initWithURL:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration;

@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic, strong) WKWebView *webView;


@end

@implementation STWindowViewController

- (instancetype)initWithURL:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration
{
    if (self = [super init]) {
        _request = request;
        _configuration = configuration;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:_configuration];
    [webView loadRequest:_request];
    [self.view addSubview:webView];
    _webView = webView;
}

@end

@interface STPreviewingViewController : UIViewController

- (instancetype)initWithURL:(NSURL *)URL previewActionItems:(NSArray *)previewActionItems;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, strong) NSArray *items;

@end

@implementation STPreviewingViewController

- (instancetype)initWithURL:(NSURL *)URL previewActionItems:(NSArray *)previewActionItems
{
    if (self = [super init]) {
        _URL = URL;
        _items = previewActionItems;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    [webView loadRequest:[NSURLRequest requestWithURL:_URL]];
    [self.view addSubview:webView];
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    return _items;
}

@end


@interface STViewController6 () <WKUIDelegate, WKNavigationDelegate>

@end

@implementation STViewController6

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"alert" style:UIBarButtonItemStylePlain target:self action:@selector(alert)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"confirm" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"prompt" style:UIBarButtonItemStylePlain target:self action:@selector(prompt)];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"3d" style:UIBarButtonItemStylePlain target:self action:@selector(preview)];
    UIBarButtonItem *item5 = [[UIBarButtonItem alloc] initWithTitle:@"new" style:UIBarButtonItemStylePlain target:self action:@selector(newWindow)];

    self.navigationItem.rightBarButtonItems = @[item1, item2, item3, item4, item5];
}

#pragma mark - Action

- (void)alert
{
    // js注入
    NSString *javaScriptSource = @"alert('注入JS');";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:userScript];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    webView.UIDelegate = self;
    [self.view addSubview:webView];
}

- (void)confirm
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    webView.UIDelegate = self;
    [self.view addSubview:webView];
    
    NSString *javaScript = @"confirm('OC调用JS')";
    [webView evaluateJavaScript:javaScript completionHandler:nil];
}

- (void)prompt
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"local3" withExtension:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    webView.UIDelegate = self;
    [self.view addSubview:webView];
}

- (void)preview
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    //配置是否允许3d touch，默认允许
    webView.allowsLinkPreview = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.qq.com"]]];
    webView.UIDelegate = self;
    [self.view addSubview:webView];
}

- (void)newWindow
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.lanrentuku.com/"]]];
    webView.UIDelegate = self;
    //通过代理将网页上所有的_blank标签都去掉
    //webView.navigationDelegate = self;
    [self.view addSubview:webView];
}

#pragma mark - WKUIDelegate

#pragma mark - JS弹框

// alert弹出框
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

// confirm弹出框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             completionHandler(NO);
                                                         }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              completionHandler(YES);
                                                          }];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:cancelAction];
    [controller addAction:confirmAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

// textInput输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(nonnull NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:prompt
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              UITextField *textField = controller.textFields.firstObject;
                                                              completionHandler(textField.text);
                                                          }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = defaultText;
    }];
    [controller addAction:confirmAction];

    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - 3D Touch

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo
{
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions
{
    if (!elementInfo.linkURL) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    // item类型为私有类WKPreviewAction
    for (id<WKPreviewActionItem> item in previewActions) {
        if ([item.identifier isEqualToString:WKPreviewActionItemIdentifierOpen]) {
            [items addObject:item];
        }
        if ([item.identifier isEqualToString:WKPreviewActionItemIdentifierAddToReadingList]) {
            [items addObject:item];
        }
        if ([item.identifier isEqualToString:WKPreviewActionItemIdentifierCopy]) {
            [items addObject:item];
        }
        if ([item.identifier isEqualToString:WKPreviewActionItemIdentifierShare]) {
            [items addObject:item];
        }
    }
    
    STPreviewingViewController *vc = [[STPreviewingViewController alloc] initWithURL:elementInfo.linkURL previewActionItems:items];
    vc.preferredContentSize = self.view.bounds.size;
    return vc;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController
{
    [self.navigationController pushViewController:previewingViewController animated:YES];
    //[self presentViewController:previewingViewController animated:YES completion:nil];
}


#pragma mark - New Window

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 当需要打开一个新窗口的时候的调用，如a标签的target='_blank'，需要返回一个新的Webview
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // 弹出新的vc
    STWindowViewController *vc = [[STWindowViewController alloc] initWithURL:navigationAction.request configuration:configuration];
    [self.navigationController pushViewController:vc animated:YES];
    return vc.webView;
    
//    WKFrameInfo *frameInfo = navigationAction.targetFrame;
//    if (![frameInfo isMainFrame]) {
//        [webView loadRequest:navigationAction.request];
//    }
//    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView
{
    NSLog(@"关闭");
}

@end
