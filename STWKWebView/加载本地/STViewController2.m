//
//  STViewController2.m
//  STWKWebView
//
//  Created by stone on 2018/11/5.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "STViewController2.h"
#import <WebKit/WebKit.h>

@interface STViewController2 ()

@end

@implementation STViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"真机加载本地" style:UIBarButtonItemStylePlain target:self action:@selector(load1)];
    self.navigationItem.rightBarButtonItems = @[item1];
}


- (void)load1
{
    //将html写入到真机中
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"local1" withExtension:@"html"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/stone.html"];
    [data writeToFile:path atomically:YES];

    url = [NSURL fileURLWithPath:path];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [self.view addSubview:webView];
    
#ifdef __IPHONE_9_0
    [webView loadFileURL:url allowingReadAccessToURL:url];
#else
    //复制到tmp/stone_html 文件夹下
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSURL *temDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"stone_html"];
    [fileManager createDirectoryAtURL:temDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    NSURL *temFile = [temDirectory URLByAppendingPathComponent:url.lastPathComponent];
    [fileManager copyItemAtURL:url toURL:temFile error:nil];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:temFile];
    [webView loadRequest:urlRequest];
#endif
}

@end
