//
//  WKWebView+Utils.m
//  FamilyEducation
//
//  Created by DoubleK on 2018/9/25.
//  Copyright © 2018年 DoubleK. All rights reserved.
//

#import "WKWebView+GW_Utils.h"

@implementation WKWebView (GW_Utils)

+ (void)setUserAgent{
    // 修改 UserAgent
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    内容需要跟后台商量
    NSString *customUserAgent = [NSString stringWithFormat:@"mobile/%@/%@ (iPhone; iOS)", [infoDictionary objectForKey:@"CFBundleIdentifier"],[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customUserAgent}];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)normolWebView{
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    [self evaluateJavaScript:jScript completionHandler:nil];
}


- (void)adjustTextIndent:(CGFloat)size{
    [self adjustTextIndent:size Company:@"pt"];
}

- (void)adjustTextIndent:(CGFloat)size Company:(NSString *)Company{
    [self adjustTextIndent:size Company:Company tag:@"p"];
}

- (void)adjustTextIndent:(CGFloat)size Company:(NSString *)Company tag:(NSString *)tag{
    //短文缩进
    NSString *test = [NSString stringWithFormat:
                      @"var objs= document.getElementsByTagName('%@');"
                      "for (i = 0; i < objs.length;i++){"
                      "var obj = objs[i];"
                      "var textIndent = %f.toString() + \"%@\";"
                      "obj.style.textIndent = textIndent;}"
                      ,tag,size,Company];
    [self evaluateJavaScript:test completionHandler:nil];
}

- (void)fontSizeAdjust:(CGFloat)size{
    [self fontSizeAdjust:size lineHeight:0];
}

- (void)fontSizeAdjust:(CGFloat)size lineHeight:(CGFloat)lineHeight{
    
    NSString *jsStringSize = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%lf%%'",size];
    
    [self evaluateJavaScript:jsStringSize completionHandler:nil];
    
    if (lineHeight != 0) {
        //行间距
        NSString *jsStringLineHeight = [NSString stringWithFormat:@"document.body.style.lineHeight=%.1f",lineHeight];
        [self evaluateJavaScript:jsStringLineHeight completionHandler:nil];
    }
}

- (void)fontColorAdjust:(NSString *)fontColor
{
    NSString *jsStringColor = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor='%@'",fontColor];
    [self evaluateJavaScript:jsStringColor completionHandler:nil];
}

- (void)resizeImageInWebView:(CGFloat)maxwidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var script = document.createElement('script');"
                          "script.type = 'text/javascript';"
                          "script.text = \"function ResizeImages() { "
                          "var myimg,oldwidth,oldheight;"
                          "var maxwidth=%f;"// 图片宽度
                          "for(i=0;i <document.images.length;i++){"
                          "myimg = document.images[i];"
                          "if(myimg.width > maxwidth){"
                          "myimg.height = (maxwidth/myimg.width)*myimg.height;"
                          "myimg.width = maxwidth;"
                          "}"
                          "}"
                          "}\";"
                          "document.getElementsByTagName('head')[0].appendChild(script);",maxwidth];
    
    [self evaluateJavaScript:jsString completionHandler:nil];

    [self evaluateJavaScript:@"ResizeImages();" completionHandler:nil];
    
    [self addClickEvent];
}

//给图片添加点击事件
- (void)addClickEvent{
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    for(var i=0;i<objs.length;i++){\
    objs[i].onclick=function(){\
    document.location=\"myweb:imageClick:\"+this.src;\
    };\
    };\
    return objs.length;\
    };";
    
    [self evaluateJavaScript:jsGetImages completionHandler:nil];
    
    [self evaluateJavaScript:@"getImages()" completionHandler:nil];
}

/**
 *  js 样式调整
 */
- (void)reLayoutTableJS_Style:(CGFloat)tableWidth{
    //修改js中table表格的宽度
    NSString *jsStrTableW = [NSString stringWithFormat:@"document.getElementsByTagName('table')[0].style.width ="
                             "\'%fpt'",tableWidth];
    [self evaluateJavaScript:jsStrTableW completionHandler:nil];
    
    NSString *tableStyle = [NSString stringWithFormat:
                            @"var tables = document.getElementsByTagName('table');"
                            "var table = tables[0];"
                            "var marginLeft = table.style.marginLeft='0pt';"
                            "var imgs = table.getElementsByTagName('img');"
                            "var myImg;"
                            "for (i = 0;i<imgs.length;i++){"
                            "myImg = imgs[i];"
                            "if (myImg.width >= 49){"
                            "myImg.width = 30;}"
                            "}"];
    [self evaluateJavaScript:tableStyle completionHandler:nil];
//    [self stringByEvaluatingJavaScriptFromString:tableStyle];
}


@end
