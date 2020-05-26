//
//  ChatListController.m
//  Whatsapp
//
//  Created by Chandrachud Patil on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "ChatController.h"
#import "MessageController.h"
#import "ChatCell.h"
#import "Chat.h"
#import "LocalStorage.h"
#import "Header.h"

@interface ChatController() <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableData;

//Temp Array
@property (strong, nonatomic) NSArray *imagesArray;

@end

@implementation ChatController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setTableView];
    [self setTest];
    //[self setTest1];
    //[self setTest2];
    [self configureNavbar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)configureNavbar
{
    self.title = @"Chat Now";
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    [leftBtn setImage:[UIImage imageNamed:@"icon - Menu.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftBarbutton = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftBarbutton;

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    [rightBtn setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarbutton;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 70, 25, 30, 30)];
    imageView.image = [UIImage imageNamed:@"user1.png"];
    //[self.navigationController.view addSubview:imageView];
    
    self.imagesArray = [NSArray arrayWithObjects:@"user 2.png",@"user.png",@"user1.png",nil];
}

-(void)setTableView
{
    self.tableData = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width, 10.0f)];
    self.tableView.backgroundColor = [UIColor clearColor];
}

-(void)setTest
{
    Contact *contact = [[Contact alloc] init];
    contact.name = @"Robo";
    contact.identifier = @"12345";
    
    Chat *chat = [[Chat alloc] init];
    chat.contact = contact;
    
    NSArray *texts = @[@"Hello!",
                       @"how can i help you"];
    
    Message *last_message = nil;
    for (NSString *text in texts)
    {
        Message *message = [[Message alloc] init];
        message.text = text;
        message.sender = MessageSenderSomeone;
        message.status = MessageStatusReceived;
        message.chat_id = chat.identifier;
        
        [[LocalStorage sharedInstance] storeMessage:message];
        last_message = message;
    }
    
    chat.numberOfUnreadMessages = texts.count;
    chat.last_message = last_message;

    [self.tableData addObject:chat];
//    [self.tableData addObject:chat];

}
-(void)setTest1
{
    Contact *contact = [[Contact alloc] init];
    contact.name = @"Robo Police";
    contact.identifier = @"12346";
    
    Chat *chat = [[Chat alloc] init];
    chat.contact = contact;
    
    NSArray *texts = @[@"Hey there",
                       @"Wanna meet for lunch"];
    
    Message *last_message = nil;
    for (NSString *text in texts)
    {
        Message *message = [[Message alloc] init];
        message.text = text;
        message.sender = MessageSenderSomeone;
        message.status = MessageStatusReceived;
        message.chat_id = chat.identifier;
        
        [[LocalStorage sharedInstance] storeMessage:message];
        last_message = message;
    }
    
    chat.numberOfUnreadMessages = texts.count;
    chat.last_message = last_message;
    
    [self.tableData addObject:chat];
    //    [self.tableData addObject:chat];
    
}
-(void)setTest2
{
    Contact *contact = [[Contact alloc] init];
    contact.name = @"Captain America";
    contact.identifier = @"12347";
    
    Chat *chat = [[Chat alloc] init];
    chat.contact = contact;
    
    NSArray *texts = @[@"Hello!",
                       @"Where are the avengers?",
                       @"Get them here",
                       @"We have a war to face"];
    
    Message *last_message = nil;
    for (NSString *text in texts)
    {
        Message *message = [[Message alloc] init];
        message.text = text;
        message.sender = MessageSenderSomeone;
        message.status = MessageStatusReceived;
        message.chat_id = chat.identifier;
        
        [[LocalStorage sharedInstance] storeMessage:message];
        last_message = message;
    }
    
    chat.numberOfUnreadMessages = texts.count;
    chat.last_message = last_message;
    
    [self.tableData addObject:chat];
    //    [self.tableData addObject:chat];
    
}


#pragma mark - TableViewDataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView != _tableView) {
        return nil;
    }

    UILabel *lbl = [[UILabel alloc]init];
    lbl.textColor = navBarColor;
    lbl.text = @"     Recent Chats";
    lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    return  lbl;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView != _tableView) {
        return 0;
    }

    return  40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != _tableView) {
        return 0;
    }
    return [self.tableData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatListCell";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.chat = [self.tableData objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[self.imagesArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != _tableView) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Message"];
    controller.chat = [self.tableData objectAtIndex:indexPath.row];
    controller.selectedIndex = indexPath.row;
    [self.navigationController pushViewController:controller animated:YES];
}

//- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
//    
//    /**
//     *  Remove content inset automatically set by UISearchDisplayController as we are forcing the
//     *  search bar to stay in the header view of the table, and not go into the navigation bar.
//     */
//    
//    [tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//    
////    
////    /**
////     *  Recalculate the bounds of our table view to account for the additional 44 pixels taken up by
////     *  the search bar, but store this in an iVar to make sure we only adjust the frame once. If we
////     *  don't store it in an iVar it adjusts the frame for every search.
////     */
////    
////    if (CGRectIsEmpty(_searchTableViewRect)) {
////        
////        CGRect tableViewFrame = tableView.frame;
////        
////        tableViewFrame.origin.y = tableViewFrame.origin.y + 44;
////        tableViewFrame.size.height =  tableViewFrame.size.height - 44;
////        
////        _searchTableViewRect = tableViewFrame;
////        
////    }
////    
////    [tableView setFrame:_searchTableViewRect];
//    
//}
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    [searchBar setShowsCancelButton:YES animated:YES];
//}
//
//
//-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    [searchBar setShowsCancelButton:NO animated:YES];
//}

@end
