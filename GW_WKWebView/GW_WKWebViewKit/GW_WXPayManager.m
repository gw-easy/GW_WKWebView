//
//  ZDOtherPManager.m
//  Zhuntiku（准题库）
//
//  Created by zdwx on 2019/4/18.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "GW_WXPayManager.h"
#define GW_URL_TIMEOUT 10

@interface GW_WXPayManager()<WKNavigationDelegate>
//如果网页请求失败，没有拦截到跳转信息时，吐司消失定时
@property (strong ,nonatomic) NSTimer *timerLever;
//跳转所需要的全拼
@property (copy, nonatomic) NSString *jumpSchemes;



@end
@implementation GW_WXPayManager

static GW_WXPayManager *base = nil;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base = [[super allocWithZone:NULL] init];
    });
    return base;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [self shareManager];
}

- (instancetype)init{
    if (self = [super init]) {
        [self webView];
    }
    return self;
}



- (void)reloadWebUrl{
    [self clearWebCache];
    [self clearToast];
    [self clearTimer];
    [self timerLever];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.currentUrl]]];
}



- (void)clearWebCache{
    if ([[[UIDevice currentDevice]systemVersion]intValue ] >= 9.0) {
        NSArray * types =@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache]; // 9.0之后才有的
        NSSet *websiteDataTypes = [NSSet setWithArray:types];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
    }else{
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSLog(@"%@", cookiesFolderPath);
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        
    }
}

+ (void)reloadWebUrl:(NSString *)url JumpAppSchemes:(NSString *)JumpAppSchemes{
    GW_WXPayShareManager.currentUrl = url;
    GW_WXPayShareManager.JumpAppSchemes = JumpAppSchemes;
    [GW_WXPayShareManager reloadWebUrl];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //    [YXToastUtil showLoadingToastForWindow:@"正在跳转"];
    NSURLRequest *request        = navigationAction.request;
    NSString     *scheme         = [request.URL scheme];
    NSString     *absoluteString = navigationAction.request.URL.absoluteString;
    NSLog(@"Current URL is %@",absoluteString);
    
    static NSString *endPayRedirectURL = nil;

    //    wap2.wangxiao.cn
    if ([absoluteString hasPrefix:@"https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb"] && ![absoluteString hasSuffix:[NSString stringWithFormat:@"redirect_url=%@",_jumpSchemes]]) {
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        NSString *redirectUrl = nil;
        if ([absoluteString containsString:@"redirect_url="]) {
            NSRange redirectRange = [absoluteString rangeOfString:@"redirect_url"];
            endPayRedirectURL =  [absoluteString substringFromIndex:redirectRange.location+redirectRange.length+1];
            redirectUrl = [[absoluteString substringToIndex:redirectRange.location] stringByAppendingString:[NSString stringWithFormat:@"redirect_url=%@",_jumpSchemes]];
        }else {
            redirectUrl = [absoluteString stringByAppendingString:[NSString stringWithFormat:@"&redirect_url=%@",_jumpSchemes]];
        }
        
        NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:redirectUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:GW_URL_TIMEOUT];
        newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
        [newRequest setHTTPMethod:@"GET"];
        [newRequest setValue:_jumpSchemes forHTTPHeaderField: @"Referer"];
        //        newRequest.URL = [NSURL URLWithString:redirectUrl];
        [webView loadRequest:newRequest];
        return;
    }
    
    // Judge is whether to jump to other app.
    if (![scheme isEqualToString:@"https"] && ![scheme isEqualToString:@"http"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([scheme isEqualToString:@"weixin"]) {
            
            if (endPayRedirectURL) {
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:endPayRedirectURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:GW_URL_TIMEOUT]];
            }
        }else if ([scheme isEqualToString:_JumpAppSchemes]) {
            [self clearToast];
            return;
        }
        
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:request.URL];
        if (canOpen) {
            if (self.jumpWXBeforeAction) {
                self.jumpWXBeforeAction();
            }
            [self clearToast];
            [self clearTimer];
            [[UIApplication sharedApplication] openURL:request.URL];
            if (self.jumpWXAfterAction) {
                self.jumpWXAfterAction();
            }
            
        }
        return;
    }
    #warning 这里换成自己的吐司Loading控件
//    [YXToastUtil showLoadingToastForWindow:@"正在跳转"];
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"error == %@",error);
    [self clearToast];
}

- (void)clearToast{
#warning 这里换成自己的吐司Loading控件
//    [YXToastUtil hiddenToastForWindow];
}

- (void)clearTimer{
    if (_timerLever) {
        [_timerLever invalidate];
        _timerLever = nil;
    }
}

#pragma mark - setter
- (void)setJumpAppSchemes:(NSString *)JumpAppSchemes{
    _JumpAppSchemes = JumpAppSchemes;
    if (JumpAppSchemes && JumpAppSchemes.length > 0) {
        GW_WXPayShareManager.jumpSchemes = [[NSString stringWithFormat:@"%@://",JumpAppSchemes] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
}

#pragma mark - getter
- (NSTimer *)timerLever{
    if (!_timerLever) {
        _timerLever = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(clearToast) userInfo:nil repeats:NO];
    }
    return _timerLever;
}
- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        self.webView.navigationDelegate = self;
        //
    }
    return _webView;
}


@end
