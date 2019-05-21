//
//  ViewController.m
//  GW_WKWebView
//
//  Created by zdwx on 2019/4/30.
//  Copyright © 2019 DoubleK. All rights reserved.
//

#import "ViewController.h"
#import "GW_WKWebViewController.h"
#import "GW_WXPayManager.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GW_WKWebViewController *webVC = [[GW_WKWebViewController alloc] init];
        webVC.webUrlString = @"http://m.baidu.com/";
        [self.navigationController pushViewController:webVC animated:YES];
    });
}

#pragma mark - 跳转到微信支付-演示代码 需要自己配置微信订单url 和 schemes
- (void)weixinPay{
    [GW_WXPayManager reloadWebUrl:@"微信订单url" JumpAppSchemes:@"微信注册顶级域名或者子域名-不用拼接://"];
}





@end
