//
//  AppDelegate.h
//  Whatsapp
//
//  Created by Chandrachud Patil on 5/22/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatBot-Swift.h"

@protocol ChatDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) id<ChatDelegate>chatDelegate;

-(void)sendMessageWithMessage:(NSString *)messageStr;

@end

@protocol ChatDelegate <NSObject>

-(void)didReceiveChatMessage:(NSDictionary *)dict;

@end