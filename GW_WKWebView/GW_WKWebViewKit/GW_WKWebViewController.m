//
//  GW_WKWebViewController.m
//  GW_WKWebView
//
//  Created by zdwx on 2019/5/10.
//  Copyright © 2019 DoubleK. All rights reserved.
//

#import "GW_WKWebViewController.h"
#import "WKWebView+GW_Utils.h"

#define GW_iPhone_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2436), [[[UIScreen mainScreen] currentMode] size]) || CGSizeEqualToSize(CGSizeMake(1242, 2688), [[[UIScreen mainScreen] currentMode] size]) || CGSizeEqualToSize(CGSizeMake(828, 1792), [[[UIScreen mainScreen] currentMode] size])) : NO)

//导航栏高度
#define GW_WEB_NavBarHeight       (GW_iPhone_X ? 88 : 64)
//tabBar高度
#define GW_WEB_TabbarHeight       (GW_iPhone_X ? 83 : 49)
//状态栏高度
#define GW_WEB_StatusBarHeight    (GW_iPhone_X ? 44 : 20)
//home indicator（home指示器）
#define GW_WEB_HomeIndicatorHeight (GW_iPhone_X ? 34 : 0)
//横屏状态下高度
#define GW_WEB_Landscape_iPhoneX_SafeArea_Width  (GW_iPhone_X ? 44 : 0)

typedef enum : NSUInteger {
//    url
    GW_loadWebURLString = 0,
//    html页面
    GW_loadWebHTMLString,
} GW_WkWebLoadType;

@interface GW_WKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
//web配置对象
@property (strong ,nonatomic) WKWebViewConfiguration *config;
//进度条
@property (strong ,nonatomic) UIProgressView *progressView;
//返回按钮
@property (strong ,nonatomic)UIBarButtonItem* customBackBarItem;
//关闭按钮
@property (strong ,nonatomic)UIBarButtonItem* closeButtonItem;
//是否存在navbar
@property (assign, nonatomic) BOOL isHaveNav;
//读取类型
@property (assign, nonatomic) GW_WkWebLoadType loadType;
@end

@implementation GW_WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _isHaveNav = self.navigationController && !self.navigationController.navigationBar.isHidden;
    
//    [WKWebView setUserAgent];
    
    
    [self webView];
    [self progressView];
    [self addKVO];
    [self chargeLoadType];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addAllUserScripts];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeAllUserScripts];
}

#pragma mark - 处理读取类型
- (void)chargeLoadType{
    if (_webUrlString && _webUrlString.length > 0) {
        _loadType = GW_loadWebURLString;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webUrlString]]];
    }else if (_HtmlString && _HtmlString.length > 0){
        _loadType = GW_loadWebHTMLString;
        [_webView loadHTMLString:_HtmlString baseURL:nil];
    }
}

#pragma mark - 刷新url
- (void)reloadWebUrl{
    [self clearWebCache];
    [self chargeLoadType];
}

#pragma mark - 清理缓存
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

#pragma mark - 添加js交互事件
- (void)addAllUserScripts{
    [_config.userContentController addScriptMessageHandler:self name:@"backButtonClicked"];
    [_config.userContentController addScriptMessageHandler:self name:@"receiveObject"];
    [_config.userContentController addScriptMessageHandler:self name:@"ShareProducts"];
    [_config.userContentController addScriptMessageHandler:self name:@"ReLogin"];
    [_config.userContentController addScriptMessageHandler:self name:@"ChangeWebViewTitle"];
    [_config.userContentController addScriptMessageHandler:self name:@"UpdateCarts"];
    [_config.userContentController addScriptMessageHandler:self name:@"ShowCarts"];
    [_config.userContentController addScriptMessageHandler:self name:@"Comment"];
    [_config.userContentController addScriptMessageHandler:self name:@"addteacherWexnumber"];
}

#pragma mark - 移除js交互事件 - 需要再viewWillDisappear移除，否则会导致循环引用
- (void)removeAllUserScripts{
    [_config.userContentController removeScriptMessageHandlerForName:@"backButtonClicked"];
    [_config.userContentController removeScriptMessageHandlerForName:@"receiveObject"];
    [_config.userContentController removeScriptMessageHandlerForName:@"ShareProducts"];
    [_config.userContentController removeScriptMessageHandlerForName:@"ReLogin"];
    [_config.userContentController removeScriptMessageHandlerForName:@"ChangeWebViewTitle"];
    [_config.userContentController removeScriptMessageHandlerForName:@"UpdateCarts"];
    [_config.userContentController removeScriptMessageHandlerForName:@"ShowCarts"];
    [_config.userContentController removeScriptMessageHandlerForName:@"Comment"];
    [_config.userContentController removeScriptMessageHandlerForName:@"addteacherWexnumber"];
}

#pragma mark ================ 自定义返回/关闭按钮 ================
-(void)updateNavigationItems{
    if (self.navigationController) {
        if (_webView.canGoBack) {
            UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            spaceButtonItem.width = -6.5;
            
            [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem,self.closeButtonItem] animated:NO];
        }else{
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem]];
        }
    }
}

#pragma mark - 返回
-(void)customBackItemClicked{
    if (_webView.canGoBack) {
        [_webView goBack];
    }else{
        [self closeItemClicked];
    }
}

#pragma mark - 关闭
-(void)closeItemClicked{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark - 添加kvo
- (void)addKVO{
    // 添加KVO监听
    [_webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [_webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [_webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

#pragma mark ================ WKScriptMessageHandler ================
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
//    js和webview交互事件 获取js的点击事件名称
    if ([message.name isEqualToString:@"userContentController"]) {
        
    }else if ([message.name isEqualToString:@"receiveObject"]){
        
    }
}

#pragma mark ================ WKNavigationDelegate ================
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    //处理短文改错正确答案显示不全的问题

//    NSString *test = [NSString stringWithFormat:
//                      @"var objs= document.getElementsByTagName('p');"
//                      "for (i = 0; i < objs.length;i++){"
//                      "var obj = objs[i];"
//                      "var textIndent = obj.style.textIndent;"
//                      "textIndent = textIndent.substring(0,textIndent.length-2);"
//                      "var num = Number(textIndent);"
//                      "var allSize = %f;"
//                      "if (num > allSize){"
//                      "num = allSize;"
//                      "textIndent = num.toString() + \"%@\";"
//                      "obj.style.textIndent = textIndent;}"
//                      "}",tag,size,Company];
//    [self evaluateJavaScript:test completionHandler:nil];
    
    
    #pragma mark - 普通webview适配样式
//    [webView normolWebView];
    
//    文字100%比例呈现
//    [webView fontSizeAdjust:100];
////    文字颜色改变
//    [webView fontColorAdjust:@"#569990"];
////    图片自适应
//    [webView reLayoutTableJS_Style:200];
//    文字缩进
    [webView adjustTextIndent:100];

//    更新返回按钮
    [self updateNavigationItems];
}

//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //    更新返回按钮
    [self updateNavigationItems];
    decisionHandler(WKNavigationActionPolicyAllow);
    
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    // 加载完成
    if (!self.webView.loading) {
        // 手动调用JS代码
        // 每次页面完成都弹出来，大家可以在测试时再打开
//        NSString *js = @"callJsAlert()";
//        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//            NSLog(@"response: %@ error: %@", response, error);
//            NSLog(@"call js alert by native");
//        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0;
        }];
    }
}

#pragma mark - getter
- (WKWebView *)webView{
    if (!_webView) {
        
        // 初始化
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, _isHaveNav?GW_WEB_NavBarHeight:GW_WEB_StatusBarHeight, self.view.bounds.size.width, _isHaveNav?self.view.bounds.size.height-GW_WEB_NavBarHeight:self.view.bounds.size.height) configuration:self.config];
        [self.view addSubview:_webView];
        _webView.backgroundColor = [UIColor redColor];
        _webView.navigationDelegate = self;
        // 与webview UI交互代理
        _webView.UIDelegate = self;
        _webView.scrollView.bounces = NO;
        
        if (@available(iOS 11,*)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _webView;
}

- (WKWebViewConfiguration *)config{
    if (!_config) {
        
        _config = [[WKWebViewConfiguration alloc] init];
        
        // 设置偏好设置
        _config.preferences = [[WKPreferences alloc] init];
        // 默认为0
        _config.preferences.minimumFontSize = 10;
        // 默认认为YES
        _config.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        _config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        // web内容处理池
        _config.processPool = [[WKProcessPool alloc] init];
        
// 通过JS与webview内容交互
        _config.userContentController = [[WKUserContentController alloc] init];
        
//        如果涉及到js调用方法需要移动端直接返回值的问题，移动端可以在页面加载前直接先将值存入web本地存储中，让js直接获取
//        WKUserScriptInjectionTimeAtDocumentStart, js加载前
//           WKUserScriptInjectionTimeAtDocumentEnd。js加载后
//        forMainFrameOnly NO(全局窗口) yes（主窗口）
        NSString *sendStr = [NSString stringWithFormat:@"localStorage.setItem(\"accessToken\",%@)",@"1234444555666777"];
        WKUserScript *uScript = [[WKUserScript alloc] initWithSource:sendStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_config.userContentController addUserScript:uScript];
        
    }
    return _config;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        // 添加进入条
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, _isHaveNav?GW_WEB_NavBarHeight:GW_WEB_StatusBarHeight, self.view.bounds.size.width, 3)];
        [self.view addSubview:_progressView];
        _progressView.backgroundColor = [UIColor redColor];
    }
    return _progressView;
}

-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"backItemImage-hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    }
    return _closeButtonItem;
}

//注意，观察的移除
-(void)dealloc{
    [_webView removeObserver:self forKeyPath:@"loading"];
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}





@end
