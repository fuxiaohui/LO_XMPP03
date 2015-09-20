//
//  ChatTableViewController.m
//  LO_XMPP01
//
//  Created by 张正 on 15/9/19.
//  Copyright (c) 2015年 张正. All rights reserved.
//

#import "ChatTableViewController.h"
#import "XMPPManager.h"
#import "MyCell.h"
#import "FriendCell.h"

@interface ChatTableViewController ()<XMPPStreamDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation ChatTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 初始化数组
    self.messageArray = [NSMutableArray array];
    
    // 给通信通道对象添加代理
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 检索信息
    [self reloadMessages];
    
    
}

- (void)reloadMessages
{
    NSManagedObjectContext *context = [XMPPManager sharedManager].context;
    
    // 创建查询类
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 创建实体描述类
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entityDescription];
    
    // 创建谓词
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ and streamBareJidStr == %@", self.friendJID.bare, [XMPPManager sharedManager].xmppStream.myJID.bare];
    
    // 创建排序类
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    // 从临时数据库中查找聊天信息
    NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:nil];
    
    if (fetchArray.count != 0) {
        
        if (self.messageArray.count != 0) {
            [self.messageArray removeAllObjects];
        }
        
        [self.messageArray addObjectsFromArray:fetchArray];
        
        [self.tableView reloadData];
        
    
    if (self.messageArray.count != 0) {
        // 动画效果
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    }
    
}

/**
 * 消息发送成功的方法
 */
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    [self reloadMessages];
}

/**
 * 消息接收成功
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    [self reloadMessages];
}

- (IBAction)sendAction:(UIBarButtonItem *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发送消息" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
        [message addBody:textField.text];
        [[XMPPManager sharedManager].xmppStream sendElement:message];
    }
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

    return self.messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // 取出数据源中的消息
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
    if (message.isOutgoing) {
        
        MyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell1" forIndexPath:indexPath];
        cell.chatLabel.text = message.body;

        return cell;
    } else {
        
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell2" forIndexPath:indexPath];
        cell.chatLabel.text = message.body;
        return cell;
    }
    

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
