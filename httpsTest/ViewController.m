//
//  ViewController.m
//  httpsTest
//
//  Created by 牛康欣 on 17/7/21.
//  Copyright © 2017年 Morise. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSString *url = @"https://www.baidu.com"  ;
    [self postWithUrl:url requestDict:param successBlcok:^(id  _Nullable resultDict ) {
        NSDictionary *dict=resultDict;
        NSLog(@"！！！！！！！！%@",dict);
        
    } faliureBlcok:^{
        NSLog(@"======");
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)postWithUrl:(NSString *)url requestDict:(NSDictionary *)requestDict successBlcok:(void (^)(id    resultDict))successBlcok faliureBlcok:(void (^)(void))errBlcok
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //自签名证书认证的方法
    [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *_credential) {
        if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust]) {
            do
            {
                SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
                NSCAssert(serverTrust != nil, @"serverTrust is nil");
                if(nil == serverTrust)
                    break; /* failed */
                /**
                 *  导入多张CA证书（Certification Authority，支持SSL证书以及自签名的CA），请替换掉你的证书名称
                 */
                NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"MORISE" ofType:@"cer"];//自签名证书
                NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
                
                NSCAssert(caCert != nil, @"caCert is nil");
                if(nil == caCert)
                    break; /* failed */
                
                SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
                NSCAssert(caRef != nil, @"caRef is nil");
                if(nil == caRef)
                    break; /* failed */
                
                //可以添加多张证书
                NSArray *caArray = @[(__bridge id)(caRef)];
                
                NSCAssert(caArray != nil, @"caArray is nil");
                if(nil == caArray)
                    break; /* failed */
                
                //将读取的证书设置为服务端帧数的根证书
                OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
                NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
                if(!(errSecSuccess == status))
                    break; /* failed */
                
                SecTrustResultType result = -1;
                //通过本地导入的证书来验证服务器的证书是否可信
                status = SecTrustEvaluate(serverTrust, &result);
                if(!(errSecSuccess == status))
                    break; /* failed */
                NSLog(@"stutas:%d",(int)status);
                NSLog(@"Result: %d", result);
                
                BOOL allowConnect = (result == kSecTrustResultUnspecified) || (result == kSecTrustResultProceed);
                if (allowConnect) {
                    NSLog(@"success");
                }else {
                    NSLog(@"error");
                }
                
                /* kSecTrustResultUnspecified and kSecTrustResultProceed are success */
                if(! allowConnect)
                {
                    break; /* failed */
                }
                
#if 0
                /* Treat kSecTrustResultConfirm and kSecTrustResultRecoverableTrustFailure as success */
                /*   since the user will likely tap-through to see the dancing bunnies */
                if(result == kSecTrustResultDeny || result == kSecTrustResultFatalTrustFailure || result == kSecTrustResultOtherError)
                    break; /* failed to trust cert (good in this case) */
#endif
                
                // The only good exit point
                NSLog(@"信任该证书");
                
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                *_credential=credential;
                
                return NSURLSessionAuthChallengeUseCredential;
                
            }
            while(0);
        }
        
        // Bad dog
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        *_credential=credential;
        return  NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }];
    
    [manager POST:url parameters:requestDict progress:nil success:^(NSURLSessionDataTask *   task, id    responseObject) {
        successBlcok(responseObject);
        
    } failure:^(NSURLSessionDataTask *   task, NSError *   error) {
        errBlcok();
    }];
}

@end
