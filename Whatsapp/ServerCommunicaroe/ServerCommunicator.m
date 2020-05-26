//
//  ServerCommunicator.m
//  ChatBot
//
//  Created by Chandrachud on 6/30/16.
//  Copyright © 2016 HummingBird. All rights reserved.
//

#import "ServerCommunicator.h"
#import "AFNetworking.h"

@implementation ServerCommunicator

-(void)uploadFileAtPath:(NSURL *)path
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *data = [NSData dataWithContentsOfURL:path];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.responseSerializer.acceptableContentTypes = nil;
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = responseSerializer;
    [manager.requestSerializer setValue:@"aac" forHTTPHeaderField:@"format"];
    [manager.requestSerializer setValue:@"audioFile" forHTTPHeaderField:@"fileName"];
    
    [manager POST:@"http://172.20.201.93:3001/uploadFile/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data
                                    name:@"files"
                                fileName:@"audioFile" mimeType:@"m4a"];
        
        // etc.
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        [self.delegate didReceiveResponse:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.delegate didFailReceiveResponse:error];
    }];
}

-(void)sendChatMesage:(NSString *)text
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parametersDictionary = [NSDictionary dictionary];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer = serializer;
    serializer.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [serializer setValue:text forHTTPHeaderField:@"message"];
    [serializer setValue:@"1" forHTTPHeaderField:@"chat_id"];
    [serializer setValue:@"1234" forHTTPHeaderField:@"flow_id"];
    
    
    [manager POST:@"http://172.20.201.93:3001/chat/" parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success!");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}
@end
