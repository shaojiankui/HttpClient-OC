//
//  ViewController.m
//  HttpClient-OC
//
//  Created by Jakey on 14-8-5.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "ViewController.h"
#import "HttpClient.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *param = @{@"action": @"cateList"};
    [HttpClient postJson:param uri:@"http://api.skyfox.org/api-test.php" jsonString:nil andBlock:^(NSDictionary *collection, NSError *error) {
        if (error) {
            NSLog(@"error%@",[error description]);
        }
        if (collection) {
            [self showAlertViewWithTitle:@"post返回" message:[collection description] delegate:nil];
            NSLog(@"return post dic =%@",[collection description]);
        }
    }];
    //获取cookie
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //NSURL *yourNSURL = [NSURL URLWithString:@"http://api.skyfox.org/api-test.php"];
    
    // NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:yourNSURL];
    //NSString *cookieString = [[operation.response allHeaderFields] valueForKey:@\\\"Set-Cookie\\\"];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"cookie%@", cookie);
    }
    
}
- (void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
    if (message == nil)
    {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
