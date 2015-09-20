//
//  XMPPManager.h
//  LO_XMPP01
//
//  Created by 张正 on 15/9/19.
//  Copyright (c) 2015年 张正. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPManager : NSObject<XMPPStreamDelegate, XMPPRosterDelegate>

// 通信通道对象
@property (nonatomic, strong) XMPPStream *xmppStream;

// 好友花名册管理对象
@property (nonatomic, strong) XMPPRoster *xmppRoster;

// 信息归档对象
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;

// 创建一个数据管理器
@property (nonatomic, strong) NSManagedObjectContext *context;

+ (XMPPManager *)sharedManager;

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password;

- (void)registerWithUserName:(NSString *)userName
                    password:(NSString *)password;

@end
