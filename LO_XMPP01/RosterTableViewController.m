//
//  RosterTableViewController.m
//  LO_XMPP01
//
//  Created by 张正 on 15/9/19.
//  Copyright (c) 2015年 张正. All rights reserved.
//

#import "RosterTableViewController.h"
#import "XMPPManager.h"
#import "ChatTableViewController.h"

@interface RosterTableViewController ()<XMPPRosterDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation RosterTableViewController


- (IBAction)addFriendAction:(UIBarButtonItem *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加好友" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        XMPPJID *jid = [XMPPJID jidWithUser:textField.text domain:kDomin resource:kResource];
        [[XMPPManager sharedManager].xmppRoster addUser:jid withNickname:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [XMPPManager sharedManager].xmppStream.myJID.user;
    
    self.dataArray = [NSMutableArray array];
    
    [[XMPPManager sharedManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

/**
 * 开始检索好友
 */
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    NSLog(@"%s__%d__| 开始检索好友", __FUNCTION__, __LINE__);
}

/**
 * 检索到好友
 */
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(DDXMLElement *)item
{
    // 取到JID字符串
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    // 创建JID对像
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    // 把jid添加到数组中
    if ([self.dataArray containsObject:jid]) {
        return;
    }
    [self.dataArray addObject:jid];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

/**
 * 检索好友结束
 */
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"%s__%d__| 检索好友结束", __FUNCTION__, __LINE__);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    
    // 取出数组中的JID对象, 给cell赋值
    XMPPJID *jid = self.dataArray[indexPath.row];
    cell.textLabel.text = jid.user;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 通过segue取到聊天页面控制器
    ChatTableViewController *chatTVC = segue.destinationViewController;
    
    // 取到cell
    UITableViewCell *cell = sender;
    
    // 找到indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // 取出JID
    XMPPJID *jid = self.dataArray[indexPath.row];

    chatTVC.friendJID = jid;
    
}


@end
