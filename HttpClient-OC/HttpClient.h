//
//  HttpClient.h
//  HttpClient-OC
//
//  Created by Jakey on 14-8-5.
//  Copyright (c) 2014年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpClient : NSObject
+ (void)postJson:(NSDictionary *)searchOption uri:(NSString*)uri jsonString:(NSString*)jsonStr andBlock:(void (^)(NSDictionary *collection, NSError *error))block;
+ (void)postForm:(NSDictionary *)param uri:(NSString*)uri jsonString:(NSString*)jsonStr andBlock:(void (^)(NSDictionary *collection, NSError *error))block;


+(NSString *)createPostBody:(NSDictionary *)params;
+ (NSMutableString *) getAbsoluteURL:(NSString *)uri withParam:(NSDictionary *)paramDic;
+ (NSDictionary *)dictionaryFromJson:(NSString*)json;
+(NSString *)jsonFromDictionary:(NSDictionary*)dic;
@end
