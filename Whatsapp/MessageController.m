//
//  MessageController.m
//  Whatsapp
//
//  Created by Chandrachud Patil on 7/23/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "MessageController.h"
#import "MessageCell.h"
#import "TableArray.h"
#import "MessageGateway.h"

#import "Inputbar.h"
#import "DAKeyboardControl.h"

//Dummy
#import "NSString+Levenshtein.h"

//For recording
#import <AVFoundation/AVFoundation.h>

#import "ServerCommunicator.h"

#import "AppDelegate.h"


@interface MessageController() <InputbarDelegate,MessageGatewayDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate,ChatDelegate,ServerCommunicatorDelegate>
{
    //Dummy Bool
    BOOL isInTheLoop;
    BOOL isRoboChat;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet Inputbar *inputbar;
@property (strong, nonatomic) TableArray *tableArray;
@property (strong, nonatomic) MessageGateway *gateway;

//Dummy Arrays for Questions and answere
@property(nonatomic, strong)NSArray *answersArr;
@property(nonatomic, strong)NSArray *questionsArr;


@property(nonatomic, strong)UILabel *titleLabel;

@property(nonatomic, strong)ServerCommunicator *serComm;
@property(nonatomic, strong)AppDelegate *appdelegate;

@end

@implementation MessageController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setInputbar];
    [self setTableView];
    [self setGateway];
    [self configureNavBar];
    self.serComm = [[ServerCommunicator alloc]init];
    _serComm.delegate = self;
    self.appdelegate = [UIApplication sharedApplication].delegate;
    self.appdelegate.chatDelegate = self;
    //Dummy
    [self fetchTempAnswers];
    isInTheLoop = NO;
    isRoboChat = NO;
    if (_selectedIndex == 0)
    {
//        isRoboChat = YES;
    }
    //Dummy
    
    
    //Recorning Code
    // Disable Stop/Play button when application launches
//    [stopButton setEnabled:NO];
//    [playButton setEnabled:NO];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak Inputbar *inputbar = _inputbar;
    __weak UITableView *tableView = _tableView;
    __weak MessageController *controller = self;
    __weak NSLayoutConstraint *inputBarConstraint = _inputBarConstraint;
    
    self.view.keyboardTriggerOffset = inputbar.frame.size.height;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        
        if (opening)
        {
            inputBarConstraint.constant = keyboardFrameInView.size.height;
        }
        else
        {
            inputBarConstraint.constant = 0;
        }
        
        CGRect toolBarFrame = inputbar.frame;
        
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        inputbar.frame = toolBarFrame;
        
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y - 64;
        tableView.frame = tableViewFrame;
        
        [controller tableViewScrollToBottomAnimated:NO];
    }];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
    [self.view removeKeyboardControl];
    [self.gateway dismiss];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.chat.last_message = [self.tableArray lastObject];
}

#pragma mark -

-(void)configureNavBar
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0,40,320,40)];
    UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(-40,0,320,40)];
    lbNavTitle.textAlignment = NSTextAlignmentLeft;
    lbNavTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    lbNavTitle.textColor = [UIColor whiteColor];
    [headerView addSubview:lbNavTitle];
    _titleLabel = lbNavTitle;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(-80, 5, 30, 30)];
    [headerView addSubview:imageView];
    self.navigationItem.titleView = headerView;
    
    //Set image and text values
    lbNavTitle.text = @"Robo";
    imageView.image = [UIImage imageNamed:@"user1.png"];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    [rightBtn setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarbutton;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

-(void)setInputbar
{
    self.inputbar.placeholder = nil;
    self.inputbar.delegate = self;
    self.inputbar.leftButtonImage = [UIImage imageNamed:@"share"];
    self.inputbar.rightButtonText = @"SEND";
    self.inputbar.rightButtonTextColor = [UIColor colorWithRed:0 green:124/255.0 blue:1 alpha:1];
}

-(void)setTableView
{
    self.tableArray = [[TableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width, 10.0f)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier: @"MessageCell"];
}

-(void)setGateway
{
    self.gateway = [MessageGateway sharedInstance];
    self.gateway.delegate = self;
    self.gateway.chat = self.chat;
    [self.gateway loadOldMessages];
}

-(void)setChat:(Chat *)chat
{
    _chat = chat;
    self.title = chat.contact.name;
}

#pragma mark - Actions

- (IBAction)userDidTapScreen:(id)sender
{
    [_inputbar resignFirstResponder];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableArray numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableArray numberOfMessagesInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.message = [self.tableArray objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.tableArray objectAtIndexPath:indexPath];
    return message.heigh;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.tableArray titleForSection:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:20.0];
    [label sizeToFit];
    label.center = view.center;
    label.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    label.backgroundColor = [UIColor colorWithRed:207/255.0 green:220/255.0 blue:252.0/255.0 alpha:1];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.autoresizingMask = UIViewAutoresizingNone;
    [view addSubview:label];
    
    return view;
}
- (void)tableViewScrollToBottomAnimated:(BOOL)animated
{
    NSInteger numberOfSections = [self.tableArray numberOfSections];
    NSInteger numberOfRows = [self.tableArray numberOfMessagesInSection:numberOfSections-1];
    if (numberOfRows)
    {
        [_tableView scrollToRowAtIndexPath:[self.tableArray indexPathForLastMessage]
                          atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark - InputbarDelegate

-(void)inputbarDidPressRightButton:(Inputbar *)inputbar
{
    [self didsendMessage:inputbar.text];
    
    Message *message = [[Message alloc] init];
    message.text = inputbar.text;
    message.date = [NSDate date];
    message.chat_id = _chat.identifier;
    
    //Store Message in memory
    [self.tableArray addObject:message];
    
    //Insert Message in UI
    NSIndexPath *indexPath = [self.tableArray indexPathForMessage:message];
    [self.tableView beginUpdates];
    if ([self.tableArray numberOfMessagesInSection:indexPath.section] == 1)
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                      withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[self.tableArray indexPathForLastMessage]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //Send message to server
    [self.gateway sendMessage:message];
}

-(void)inputbarDidPressLeftButton:(Inputbar *)inputbar
{
    //record an audio
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Left Button Pressed"
//                                                        message:nil
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil, nil];
   // [alertView show];
    
}

-(void)inputbarDidChangeHeight:(CGFloat)new_height
{
    //Update DAKeyboardControl
    self.view.keyboardTriggerOffset = new_height;
}

-(void)inputbarDidPressLeftBarButtonForLong:(UILongPressGestureRecognizer *)gesture
{
    if ( gesture.state == UIGestureRecognizerStateEnded )
    {
        NSLog(@"Long Press ENDED");
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        _titleLabel.text = @"Robo";

    }
    
    else if (gesture.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"Long Press BEGAN");
        [self startRecording];
        _titleLabel.text = @"Recording...";
    }
}

#pragma mark - MessageGatewayDelegate

-(void)gatewayDidUpdateStatusForMessage:(Message *)message
{
    NSIndexPath *indexPath = [self.tableArray indexPathForMessage:message];
    MessageCell *cell = (MessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateMessageStatus];
}

-(void)gatewayDidReceiveMessages:(NSArray *)array
{
    [self.tableArray addObjectsFromArray:array];
    [self.tableView reloadData];
}

#pragma mark - Answering back Methods

-(void)didsendMessage:(NSString*)message
{
    message = [message lowercaseString];
//    [self.appdelegate sendMessageWithMessage:message];
    [self.serComm sendChatMesage:message];
    /*
    if (isRoboChat) {
        return;
    }
    if ([message containsString:@"subscribe"] || [message containsString:@"subscription"]) {
        [self startRoboChatWithMessage:message];
        return;
    }
    NSMutableArray *mutableArray = [NSMutableArray array];
    for(NSString *question in _questionsArr)
    {
        CGFloat comparison = [question compareWithString:message matchGain:1 missingCost:1];
        //NSLog(@"%f",comparison);
        [mutableArray addObject:[NSNumber numberWithFloat:comparison]];
    }
    
    __block float xmax = -MAXFLOAT;
    __block float xmin = MAXFLOAT;
    [mutableArray enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
        float x = num.floatValue;
        if (x < xmin) xmin = x;
        if (x > xmax) xmax = x;
    }];
    
    if (xmin > 1) {
        //        [self performSelector:@selector(replyTotheMessage:) withObject:@"" afterDelay:6.0];
        return;
    }
    
    NSInteger index = [mutableArray indexOfObject:[NSNumber numberWithFloat:xmin]];
    
    NSArray *answerAray = [_answersArr objectAtIndex:index];
    
    if (!isInTheLoop) {
        for (NSString *answer in answerAray)
        {
            NSInteger integer = [answerAray indexOfObject:answer];
            [self performSelector:@selector(replyTotheMessage:) withObject:answer afterDelay:6.0 + integer+1];
        }
    }
    //If index is 6, problem with something has been lost is shared send additional messages
    if (index == 6)
    {
        isInTheLoop = YES;
        if ([message containsString:@"phone"]) {
            [self performSelector:@selector(replyTotheMessage:) withObject:@"Can you share your phone number and IMEI number" afterDelay:10.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"We will get our team to investigate this" afterDelay:14.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"Where did you lose it" afterDelay:35.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"Thanks for sharing the information" afterDelay:65.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"We will do our best locate your phone" afterDelay:67.0];
            
            return;
        }
        else if([message containsString:@"car"])
        {
            [self performSelector:@selector(replyTotheMessage:) withObject:@"Can you share your car number and Model name" afterDelay:10.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"We will get our team to investigate this" afterDelay:14.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"Where did you lose it" afterDelay:35.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"Thanks for sharing the information" afterDelay:65.0];
            [self performSelector:@selector(replyTotheMessage:) withObject:@"We will do our best to get this resolved" afterDelay:67.0];
            
            return;
        }
        [self performSelector:@selector(undoFlag) withObject:nil afterDelay:77.0];
    }
     */
}

-(void)undoFlag
{
    isInTheLoop = NO;
    isRoboChat = NO;
}

-(void)replyTotheMessage:(NSString *)ansString
{
    Message *message = [[Message alloc] init];
    message.text = ansString;
    message.date = [NSDate date];
    message.chat_id = _chat.identifier;
    message.sender = MessageSenderSomeone;
    [self.tableArray addObject:message];
    
    //Insert Message in UI
    NSIndexPath *indexPath = [self.tableArray indexPathForMessage:message];
    [self.tableView beginUpdates];
    if ([self.tableArray numberOfMessagesInSection:indexPath.section] == 1)
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                      withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[self.tableArray indexPathForLastMessage]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.gateway sendMessage:message];
    
    //    [self.tableView reloadData];
}

-(void)fetchTempAnswers
{
    _answersArr =  [self parseLocalJSON:@"Answers"];
    _questionsArr = [self parseLocalJSON:@"Questions"];
}

-(id)parseLocalJSON:(NSString*)fileName
{
    // NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
    
    // serialize the request JSON
    NSError *error;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *tempData = [NSData dataWithContentsOfFile:filePath];
    // NSDictionary *tempDict = [[NSDictionary alloc]init];
    
    id tempDict = [NSJSONSerialization
                   JSONObjectWithData:tempData
                   
                   options:kNilOptions
                   error:&error];
    //    NSArray *arrTemp = [tempDict objectForKey:@"Answers"];
    return tempDict;
}

-(void)startRoboChatWithMessage:(NSString *)message
{
    isRoboChat = YES;
    message = [message lowercaseString];
//    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

    if ([message containsString:@"yes"])
    {
    [self performSelector:@selector(replyTotheMessage:) withObject:@"Ok" afterDelay:6.0];
    }
   else if ([message containsString:@"subscribed"])
   {
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Good that you are already subscribed" afterDelay:6.0];
   }
   else if ([message containsString:@"subscription"] || [message containsString:@"subscribe"])
   {
//       [self performSelector:@selector(replyTotheMessage:) withObject:@"Good that you are already subscribed" afterDelay:6.0];
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Can you provide us with some information so we can process your form" afterDelay:7.0];
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Thanks" afterDelay:20.0];
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Please tell us your first name and last name" afterDelay:22.0];

       [self performSelector:@selector(replyTotheMessage:) withObject:@"Thats Cool" afterDelay:36.0];
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Please tell us last four digits of your SSN" afterDelay:40.0];

       [self performSelector:@selector(replyTotheMessage:) withObject:@"This number cannot be alpha numeric" afterDelay:56.0];
       
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Thats good" afterDelay:72.0];
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Please share your email address" afterDelay:75.0];

       [self performSelector:@selector(replyTotheMessage:) withObject:@"Awesome! " afterDelay:100.0];
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Please click on the link we have sent to you on your mail and you are subscribed" afterDelay:102.0];
       [self performSelector:@selector(replyTotheMessage:) withObject:@"Welcome " afterDelay:104.0];

       [self performSelector:@selector(undoFlag) withObject:nil afterDelay:103.0];
   }
    
    else if ([message containsString:@""])
    {
        [self performSelector:@selector(replyTotheMessage:) withObject:@"Thats good" afterDelay:6.0];
    }
}

#pragma mark - Audio Delegates
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    if (!recorder.recording)
    {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        
        [player setDelegate:self];
//        [player play];
        [_serComm uploadFileAtPath:recorder.url];
        
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
//                                                    message: @"Finish playing the recording!"
//                                                   delegate: nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:@"We have received your query. Please sit back and relax untill we get it resolved for you!"];
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];

}

#pragma MARK - OTHER AUDIO METHODS
-(void)startRecording
{
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        
    } else {
        
        // Pause recording
        [recorder pause];
    }
}

#pragma mark ChatDelegate MethodsK
 -(void)didReceiveChatMessage:(NSDictionary *)dict
{
    [self replyTotheMessage:@""];
}
#pragma mark ServerComm Methods

-(void)didReceiveResponse:(NSDictionary *)dict
{
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:@"We have received your query. Please sit back and relax untill we get it resolved for you!"];
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}

-(void)didFailReceiveResponse:(NSError *)error
{
    NSLog(@"Failed to receive Response");
}

#pragma mark - Other Recordings

@end
