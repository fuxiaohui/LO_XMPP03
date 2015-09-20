//
//  ChatTableViewController.h
//  LO_XMPP01
//
//  Created by 张正 on 15/9/19.
//  Copyright (c) 2015年 张正. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@interface ChatTableViewController : UITableViewController

@property (nonatomic, strong) XMPPJID *friendJID;

@end
