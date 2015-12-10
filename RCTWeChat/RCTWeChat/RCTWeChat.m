//
//  RCTWeChat.m
//  RCTWeChat
//
//  Created by xiaoyan on 15/12/10.
//  Copyright © 2015年 ziyan. All rights reserved.
//

#import "RCTWeChat.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "WXApi.h"
#import "WXApiObject.h"

static RCTWeChat* instance = nil;

@implementation RCTWeChat

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

+ (instancetype)shareInstance {
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (!instance) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    [WXApi handleOpenURL:url delegate:instance];
    return true;
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        
        NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:
                              authResp.code, @"code",
                              authResp.state, @"state",
                              authResp.errCode, @"errCode", nil];
        
        [self.bridge.eventDispatcher sendAppEventWithName:@"finishedAuth"
                                                        body:body];
    }
}

- (void)onReq:(BaseReq *)req {
}


// 注册微信应用ID
RCT_EXPORT_METHOD(registerApp:(NSString *)appid
                  :(RCTResponseSenderBlock)callback)
{
    BOOL res = [WXApi registerApp:appid];
    if (callback) {
        callback(@[@(res)]);
    }
}

// 检测是否已安装微信
RCT_EXPORT_METHOD(isWXAppInstalled:(RCTResponseSenderBlock)callback)
{
    callback(@[@([WXApi isWXAppInstalled])]);
}

//
RCT_EXPORT_METHOD(sendAuthRequest:(NSString *)state
                  :(RCTResponseSenderBlock)callback)
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = state;
    [WXApi sendReq:req];
    callback(@[[NSNull null]]);
}

@end