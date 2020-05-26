//
//  ChatController.h
//  Whatsapp
//
//  Created by Chandrachud Patil on 5/22/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

//
// This class control chat exchange message itself
// It creates the bubble UI
//
@interface MessageController : UIViewController
@property (strong, nonatomic) Chat *chat;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputBarConstraint;

@property(assign,nonatomic) NSInteger selectedIndex;

@end
