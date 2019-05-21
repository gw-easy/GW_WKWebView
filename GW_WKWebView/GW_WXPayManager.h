//
//  ZDOtherPManager.h
//  Zhuntiku（准题库）
//
//  Created by zdwx on 2019/4/18.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#define GW_WXPayShareManager [GW_WXPayManager shareManager]
NS_ASSUME_NONNULL_BEGIN

@interface GW_WXPayManager : NSObject

/**
 webView 没有frame 如果需要再外界展示，请自行设置
 */
@property (strong, nonatomic) WKWebView *webView;

/**
 需要传入的当前微信付款订单url
 */
@property (nonatomic, copy) NSString *currentUrl;

/**
 跳转Schemes 1.需要再info里面配置schemes信息。 2.这个是在微信注册的顶级域名或者顶级域名的子域名。需要跟后台约定好，否则跳转过去后，回不来。
 */
@property (copy, nonatomic) NSString *JumpAppSchemes;

/**
 跳转微之前操作
 */
@property (copy, nonatomic) void(^jumpWXBeforeAction)(void);

/**
 跳转微之后操作
 */
@property (copy, nonatomic) void(^jumpWXAfterAction)(void);

//单例
+ (instancetype)shareManager;

/**
 刷新url
 */
- (void)reloadWebUrl;

/**
 清理缓存
 */
- (void)clearWebCache;

/**
 跳转

 @param url 支付url
 @param JumpAppSchemes 跳转到app所需要的前缀
 */
+ (void)reloadWebUrl:(NSString *)url JumpAppSchemes:(NSString *)JumpAppSchemes;
@end

NS_ASSUME_NONNULL_END
