//
//  WKWebView+Utils.h
//  FamilyEducation
//
//  Created by DoubleK on 2018/9/25.
//  Copyright © 2018年 DoubleK. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (GW_Utils)

/**
 配置UserAgent 后台根据这个值判断网页请求的来源
 */
+ (void)setUserAgent;

/**
 普通加载模式，跟UIWebview加载的视图相似,用于后台返回h5形式页面加载
 */
- (void)normolWebView;


/**
 文本缩进 对p标签的处理

 @param size 缩进数量 单位是pt
 */
- (void)adjustTextIndent:(CGFloat)size;


/**
 文本缩进 对p标签的处理
 
 @param size 缩进数量 单位是pt
 @param Company 缩进单位 如pt px等
 */
- (void)adjustTextIndent:(CGFloat)size Company:(NSString *)Company;


/**
 文本缩进
 
 @param size 缩进数量 单位是pt
 @param Company 缩进单位 如pt px等
 @param tag 需要处理的标签 如p， h1~h6等
 */
- (void)adjustTextIndent:(CGFloat)size Company:(NSString *)Company tag:(NSString *)tag;

/**
 字号调整
 
 @param size 字号
 */
- (void)fontSizeAdjust:(CGFloat)size;

/**
 字号调整 行高调整

 @param size 字体缩放比例
 @param lineHeight 行高
 */
- (void)fontSizeAdjust:(CGFloat)size lineHeight:(CGFloat)lineHeight;

/**
 字体颜色调整

 @param fontColor 字体颜色，只支持hex格式
 */
- (void)fontColorAdjust:(NSString *)fontColor;

/**
 使用js对图片大小进行自适应

 @param maxwidth 图片的最大宽度
 */
- (void)resizeImageInWebView:(CGFloat)maxwidth;

/**
 网页表格样式调整

 @param tableWidth 表格宽度
 */
- (void)reLayoutTableJS_Style:(CGFloat)tableWidth;


@end
