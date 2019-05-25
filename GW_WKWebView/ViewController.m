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
//        webVC.webUrlString = @"http://m.baidu.com/";
        webVC.HtmlString = @"<p>一盏一直亮着的灯，你不会去注意，但是如果它一亮一灭，你就会注意到。</p><p>每天吃饭、睡觉、上学、上班，你不会觉得自己幸福，但是当有一天你遭遇了大病、失业、失学、失亲，然后，事情过了，你突然对眼前的一切特别珍视。你觉得太感谢老天，觉得老天太厚待自己，觉得自己太幸福了。</p><p>这就叫“人在福中不知福”，只有当某一天，把你拉出福去，你才懂得。</p><p>有一首流行老歌《思念总在分手后》讲的也是这个道理：两个人天天在一起，越来越觉得平淡，直到厌了、分了，才突然发觉“过去的深情”。</p><p>工作也一样。你会发现许多人有着令大家羡慕的工作，但是某一天，他居然辞了职。</p><p>最后，他另找工作，却再也找不到像过去那么好的。</p><p>你可以猜：那时候，他一定会偷偷后悔。</p><p>问题是——这是人性。</p><p>人天生就喜欢冒险、喜欢新奇、喜欢云霄飞车的感觉，也可以说人天生就不喜欢“过度的平静”。</p><p>所以，你处在一个隔音室里，四周一点点声音都没有，你不见得感觉宁静，你反而会听到一种近乎耳鸣的喧哗声从你身体里面发出。相反，如果你置身在森林，有竹韵、松涛、鸟啭、虫鸣、水流，你却觉得宁静极了。</p><p>人不能长处在平静之中，太平静、太没变化，会使人不安，甚至发疯。</p><p>于是聪明的医生，当你没病找病，去找他诉苦的时候，即使他一眼就看出你没毛病，也会细细地听听、打打、敲敲、压压，再神情严肃地开几味药(天知道!可能只是维生素、镇静剂)，又叮嘱你“过两个星期再来”。</p><p>两个星期之后，你又去了，他再细细检查，笑说有进步，又开药，又要你隔周再来。</p><p>你又去了，他检查、再检查，拍拍你的肩：“恭喜你，病全好了。”你岂不是感激涕零，要谢谢他这位神医吗?</p><p>懂得经营大企业的老板，绝不提早发布“今年会发多少年终奖金”的消息，因为当你这么一说，就变成了“当然”，你当然得信守诺言，当然得“如数发给”。</p><p>于是，从你这么一说，你就欠员工的。</p><p>反而是，你可以先放空气，说今年的景气不好，怕发不出来，甚至有可能裁员。于是人心惶惶，员工非但不再指望发多少年终奖金，而是生怕自己被裁。</p><p>结果，当你不但不裁员，反而说“亏损由我吃下，员工福利不可少”，而再多多少少发了些奖金时，你得到的是掌声，是感谢，是坐云霄飞车，吓得半死之后终于到站的笑容。你很高明!对不对?</p><p>这就是人性!人性多么可悲啊，人居然像猴子，由“朝三暮四”，换成“朝四暮三”，换汤不换药，猴子就会高兴。</p><p>问题是，作为人，如果没点儿合理与不合理的变化，生活还有什么意思?</p>";
        [self.navigationController pushViewController:webVC animated:YES];
    });
}

#pragma mark - 跳转到微信支付-演示代码 需要自己配置微信订单url 和 schemes
- (void)weixinPay{
    [GW_WXPayManager reloadWebUrl:@"微信订单url" JumpAppSchemes:@"微信注册顶级域名或者子域名-不用拼接://"];
}





@end
