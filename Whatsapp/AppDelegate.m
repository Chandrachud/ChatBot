//
//  AppDelegate.m
//  Whatsapp
//
//  Created by Chandrachud Patil on 5/22/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property(nonatomic, strong) SocketIOClient *socket;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initSocket];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)initSocket
{
//    self.socket = [[SocketIOClient alloc]initWithSocketURL:@"" options:nil];
    self.socket = [[SocketIOClient alloc] initWithSocketURL:@"http://172.20.201.93:8080/chat" options:@{@"log": @YES, @"forcePolling": @NO}];
    [self addHandlers];
    
    [self.socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
        double cur = [[data objectAtIndex:0] floatValue];
        
        [self.socket emitWithAck:@"canUpdate" withItems:@[@(cur)]](0, ^(NSArray* data) {
            [self.socket emit:@"update" withItems:@[@{@"amount": @(cur + 2.50)}]];
        });
        
        [ack with:@[@"Got your currentAmount, ", @"dude"]];
    }];

//    [self.socket connect];
}

-(void)addHandlers
{
    
    [self.socket onAny:^(SocketAnyEvent * _Nonnull data) {
        NSLog(@"Got Event");
        [self.socket on:@"connect" callback:^(NSArray * _Nonnull array, SocketAckEmitter * _Nullable emitter) {
            NSLog(@"Connecting....");
        }];
        
        [self.socket on:@"Chat" callback:^(NSArray * _Nonnull receivedArray, SocketAckEmitter * _Nullable chatData) {
            
            [self.chatDelegate didReceiveChatMessage:(NSDictionary *)receivedArray];
        }];
    }];
}

- (void)didConnect
{
    NSLog(@"Succesfully opened the socket");
}
- (void)didDisconnect:(NSString * _Nonnull)reason
{
    NSLog(@"Some error occurred \n Trying again...");
}

-(void)sendMessageWithMessage:(NSString *)messageStr
{
    NSArray *array = [NSArray arrayWithObject:messageStr];
    [self.socket emit:@"Chat" withItems:array];
}
- (void)didError:(id _Nonnull)reason;
{

}
- (void)connectWithTimeoutAfter:(NSInteger)timeoutAfter withTimeoutHandler:(void (^ _Nullable)(void))handler;
{
    
}
@end
