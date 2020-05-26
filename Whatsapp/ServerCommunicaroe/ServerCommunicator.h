//
//  ServerCommunicator.h
//  ChatBot
//
//  Created by Chandrachud on 6/30/16.
//  Copyright © 2016 HummingBird. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerCommunicatorDelegate;

@interface ServerCommunicator : NSObject

@property(nonatomic,assign) id<ServerCommunicatorDelegate>delegate;

-(void)uploadFileAtPath:(NSURL *)path;
-(void)sendChatMesage:(NSString *)text;
@end
@protocol ServerCommunicatorDelegate <NSObject>

-(void)didReceiveResponse:(NSDictionary *)dict;
-(void)didFailReceiveResponse:(NSError *)error;

@end