//
//  AFN.m
//  httpsTest
//
//  Created by 牛康欣 on 2018/9/5.
//  Copyright © 2018年 Morise. All rights reserved.
//

#import "AFN.h"

@implementation AFN
//网络工具的类方法，单例模式
+(instancetype)sharedTools{
    static AFN *sharedTools;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL *baseUrl = [NSURL URLWithString:@"http://httpbin.org/"];
        sharedTools = [[self alloc] initWithBaseURL:baseUrl];
        
    });
    return sharedTools;
}
@end
