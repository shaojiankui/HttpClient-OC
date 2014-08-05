//
//  HttpClient.m
//  HttpClient-OC
//
//  Created by Jakey on 14-8-5.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "HttpClient.h"

@implementation HttpClient
+ (void)postJson:(NSDictionary *)param uri:(NSString*)uri jsonString:(NSString*)jsonStr andBlock:(void (^)(NSDictionary *collection, NSError *error))block {
    
    NSURL *url = [NSURL URLWithString:uri];
    
    NSString *post = [NSString string];
    if (param!=nil) {
        post= [self jsonFromDictionary:param];
    }
    if (jsonStr!=nil) {
        post = jsonStr;
    }
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:10.0];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy]; // 设置缓存策略
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               //取cookie
                               NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                               NSDictionary *fields = [HTTPResponse allHeaderFields];
                               NSLog(@"fields = %@",[fields description]);
                               // NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:url];
                               //NSString *cookieString = [[HTTPResponse allHeaderFields] valueForKey:@"Set-Cookie"];
                               
                               NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                               for (NSHTTPCookie *cookie in [cookieJar cookies]) {
                                   NSLog(@"cookie%@", cookie);
                               }
                               //end cookie
                               
                               
                               NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               //responseString = [self trimBackSlash:responseString];
                               
                               NSDictionary *dic = [self dictionaryFromJson:responseString];
                               
                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                   
                                   if (error) {
                                       block(nil,error);
                                   }else{
                                       block(dic,nil);
                                   }
                               });
                           }];
    
}

+ (void)postForm:(NSDictionary *)param uri:(NSString*)uri jsonString:(NSString*)jsonStr andBlock:(void (^)(NSDictionary *collection, NSError *error))block {
    
    NSURL *url = [NSURL URLWithString:uri];
    
    NSString *post = [NSString string];
    if (param!=nil) {
        post = [self createPostBody:param];
    }
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //[request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //[request setValue:@"application/x-www-data-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    [request setTimeoutInterval:10.0];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *dic = [self dictionaryFromJson:responseString];
                               
                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                   
                                   if (error) {
                                       block(nil,error);
                                   }else{
                                       block(dic,nil);
                                   }
                                   
                               });
                           }];
    
}


//工具方法
+(NSString *)createPostBody:(NSDictionary *)params

{
    NSString *postString=@"";
    for(NSString *key in [params allKeys])
    {
        NSString *value= [params objectForKey:key];
        postString =[postString stringByAppendingFormat:@"%@=%@&",key,value];
    }
    if([postString length] > 1)
    {
        postString=[postString substringToIndex:[postString length]-1];
    }
    return postString;
}


+ (NSMutableString *) getAbsoluteURL:(NSString *)uri withParam:(NSDictionary *)paramDic
{
    
    NSMutableString *absUrl = [NSMutableString stringWithString:uri];
    
    if (paramDic != nil) {
        NSArray *keys = [paramDic allKeys];
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (obj != nil) {
                if (idx ==0) {
                    [absUrl stringByAppendingFormat:@"?%@=%@", obj, [paramDic valueForKey:obj]];
                }else{
                    [absUrl stringByAppendingFormat:@"&%@=%@", obj, [paramDic valueForKey:obj]];
                }
            }
        }];
        
    }
    absUrl = (NSMutableString*)[absUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return absUrl;
}

+ (NSDictionary *)dictionaryFromJson:(NSString*)json{
    NSError *errorJson;
    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&errorJson];
    return ret;
}


+(NSString *)jsonFromDictionary:(NSDictionary*)dic{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}

+(NSString*)trimBackSlash:(NSString*)string{
    
    NSMutableString *responseString = [NSMutableString stringWithString:string];
    NSString *character = nil;
    for (int i = 0; i < responseString.length; i ++) {
        character = [responseString substringWithRange:NSMakeRange(i, 1)];
        if ([character isEqualToString:@"\\"])
            [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
    }
    return responseString;
}
//URLEncode
+(NSString*)encodeString:(NSString*)unencodedString{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}
//URLDEcode
+(NSString *)decodeString:(NSString*)encodedString

{
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)self,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}
@end

