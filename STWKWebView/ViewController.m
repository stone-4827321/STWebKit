//
//  ViewController.m
//  STWKWebView
//
//  Created by stone on 2018/11/2.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "ViewController.h"
#import "STViewController1.h"
#import "STViewController2.h"
#import "STViewController3.h"
#import "STViewController4.h"
#import "STViewController5.h"
#import "STViewController6.h"
#import "STViewController7.h"
#import "STViewController8.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = NO;

    NSArray *array = @[@"基本使用",
                       @"加载本地资源",
                       @"缓存",
                       @"JS交互",
                       @"WKNavigationDelegate",
                       @"WKUIDelegate",
                       @"post参数",
                       @"拦截"
                       ];
    for(int i = 0; i < array.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:array[i] forState:UIControlStateNormal];
        button.tag = i + 1;
        button.frame = CGRectMake(0, 10 + 50 * i, 300, 44);
        [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)clicked:(UIButton *)btn
{
    UIViewController *vc;
    if (btn.tag == 1) {
        vc = [[STViewController1 alloc] init];
    }
    else if (btn.tag == 2) {
        vc = [[STViewController2 alloc] init];
    }
    else if (btn.tag == 3) {
        vc = [[STViewController3 alloc] init];
    }
    else if (btn.tag == 4) {
        vc = [[STViewController4 alloc] init];
    }
    else if (btn.tag == 5)
    {
        vc = [[STViewController5 alloc] init];
    }
    else if (btn.tag == 6)
    {
        vc = [[STViewController6 alloc] init];
    }
    else if(btn.tag == 7)
    {
        vc = [[STViewController7 alloc] init];
    }
    else if(btn.tag == 8)
    {
        vc = [[STViewController8 alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}



@end
