//
//  GW_WKWebViewController.h
//  GW_WKWebView
//
//  Created by zdwx on 2019/5/10.
//  Copyright © 2019 DoubleK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface GW_WKWebViewController : UIViewController

@property (strong ,nonatomic) WKWebView *webView;
//请求url
@property (copy, nonatomic) NSString *webUrlString;

/**
 请求html页面
 */
@property (copy, nonatomic) NSString *HtmlString;

/**
 刷新url
 */
- (void)reloadWebUrl;

/**
 清理缓存
 */
- (void)clearWebCache;
@end

NS_ASSUME_NONNULL_END
